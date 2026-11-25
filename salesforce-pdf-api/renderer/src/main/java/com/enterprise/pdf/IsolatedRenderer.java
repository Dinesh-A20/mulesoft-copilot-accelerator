package com.enterprise.pdf;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Set;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;

/** FR-07, CON-06: only the owned child is killed; capacity is held until actual exit. */
public final class IsolatedRenderer {
    private static final int MAX_BYTES = 2 * 1024 * 1024;
    private static final Semaphore SLOTS = new Semaphore(5);
    private static final Set<Process> CHILDREN = ConcurrentHashMap.newKeySet();
    private static final ScheduledExecutorService WATCHDOG = Executors.newSingleThreadScheduledExecutor(
            task -> daemon(task, "pdf-deadline"));
    private static final AtomicBoolean CLOSED = new AtomicBoolean();
    private static Path bundledJar;
    private static final Thread SHUTDOWN_HOOK = new Thread(IsolatedRenderer::shutdown, "pdf-shutdown");

    static {
        Runtime.getRuntime().addShutdownHook(SHUTDOWN_HOOK);
    }

    private IsolatedRenderer() {}

    public static String javaExecutable() {
        String binary = System.getProperty("os.name").startsWith("Windows") ? "java.exe" : "java";
        return Path.of(System.getProperty("java.home"), "bin", binary).toString();
    }

    public static synchronized String rendererJar() throws IOException {
        if (CLOSED.get()) {
            throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
        }
        if (bundledJar == null) {
            ClassLoader loader = Thread.currentThread().getContextClassLoader();
            InputStream found = loader == null ? null : loader.getResourceAsStream("renderer/renderer.jar");
            if (found == null) {
                found = IsolatedRenderer.class.getResourceAsStream("/renderer/renderer.jar");
            }
            try (InputStream resource = found) {
                if (resource == null) {
                    throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
                }
                Path directory = Files.createTempDirectory("account-pdf-code-");
                Path candidate = directory.resolve("renderer.jar");
                try {
                    Files.copy(resource, candidate);
                    bundledJar = candidate;
                } catch (IOException e) {
                    try {
                        Files.deleteIfExists(candidate);
                        Files.deleteIfExists(directory);
                    } catch (IOException cleanup) {
                        e.addSuppressed(cleanup);
                    }
                    throw e;
                }
            }
        }
        return bundledJar.toString();
    }

    public static byte[] render(String html, String javaExecutable, String rendererJar, Long deadline) {
        RuntimeSupport.requireBudget(deadline, 1L);
        byte[] input = html.getBytes(StandardCharsets.UTF_8);
        if (input.length > MAX_BYTES) {
            throw new PdfFailure("PDF_SIZE_EXCEEDED");
        }
        if (!Files.isRegularFile(Path.of(rendererJar)) || !Files.isRegularFile(Path.of(javaExecutable))) {
            throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
        }
        if (CLOSED.get() || !SLOTS.tryAcquire()) {
            throw new PdfFailure("CAPACITY_EXCEEDED");
        }
        Process child = null;
        ScheduledFuture<?> alarm = null;
        ExecutorService io = Executors.newFixedThreadPool(2, task -> daemon(task, "pdf-pipe"));
        AtomicBoolean released = new AtomicBoolean();
        long end = Math.min(deadline, System.nanoTime() + TimeUnit.SECONDS.toNanos(5));
        try {
            child = new ProcessBuilder(javaExecutable, "-Xms16m", "-Xmx128m",
                    "-XX:-HeapDumpOnOutOfMemoryError", "-XX:-CreateCoredumpOnCrash",
                    "-XX:ErrorFile=" + (System.getProperty("os.name").startsWith("Windows") ? "NUL" : "/dev/null"),
                    "-Djava.awt.headless=true",
                    "-jar", rendererJar).redirectError(ProcessBuilder.Redirect.DISCARD).start();
            Process owned = child;
            CHILDREN.add(owned);
            owned.onExit().thenRun(() -> {
                CHILDREN.remove(owned);
                if (released.compareAndSet(false, true)) {
                    SLOTS.release();
                }
                if (CLOSED.get() && CHILDREN.isEmpty()) {
                    cleanupCode();
                }
            });
            if (CLOSED.get()) {
                owned.destroyForcibly();
                throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
            }
            alarm = WATCHDOG.schedule(owned::destroyForcibly,
                    Math.max(0, end - System.nanoTime()), TimeUnit.NANOSECONDS);
            Future<?> writer = io.submit(() -> {
                try (var stdin = owned.getOutputStream()) {
                    stdin.write(input);
                } catch (IOException e) {
                    throw new CompletionException(e);
                }
            });
            Future<byte[]> reader = io.submit(() -> boundedRead(owned.getInputStream()));
            writer.get(timeLeft(end), TimeUnit.NANOSECONDS);
            byte[] pdf = reader.get(timeLeft(end), TimeUnit.NANOSECONDS);
            if (!owned.waitFor(timeLeft(end), TimeUnit.NANOSECONDS)) {
                throw new TimeoutException();
            }
            if (owned.exitValue() == 3) {
                throw new PdfFailure("PDF_SIZE_EXCEEDED");
            }
            if (owned.exitValue() != 0 || pdf.length < 5
                    || !new String(pdf, 0, 5, StandardCharsets.US_ASCII).equals("%PDF-")) {
                throw new PdfFailure("INTERNAL_ERROR");
            }
            RuntimeSupport.requireBudget(deadline, 1L);
            return pdf;
        } catch (TimeoutException e) {
            throw new PdfFailure("TIMEOUT");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new PdfFailure("TIMEOUT");
        } catch (ExecutionException e) {
            Throwable cause = e.getCause();
            if (cause instanceof PdfFailure failure) {
                throw failure;
            }
            if (System.nanoTime() >= end) {
                throw new PdfFailure("TIMEOUT");
            }
            throw new PdfFailure("INTERNAL_ERROR");
        } catch (IOException e) {
            throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
        } catch (RejectedExecutionException e) {
            throw new PdfFailure("DEPENDENCY_UNAVAILABLE");
        } finally {
            if (alarm != null) {
                alarm.cancel(false);
            }
            if (child != null && child.isAlive()) {
                child.destroyForcibly();
            } else if (child == null && released.compareAndSet(false, true)) {
                SLOTS.release();
            }
            io.shutdownNow();
        }
    }

    private static long timeLeft(long end) throws TimeoutException {
        long remaining = end - System.nanoTime();
        if (remaining <= 0) {
            throw new TimeoutException();
        }
        return remaining;
    }

    static byte[] boundedRead(InputStream source) throws IOException {
        try (source; var bytes = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[8192];
            int count;
            while ((count = source.read(buffer)) != -1) {
                if (bytes.size() + count > MAX_BYTES) {
                    throw new PdfFailure("PDF_SIZE_EXCEEDED");
                }
                bytes.write(buffer, 0, count);
            }
            return bytes.toByteArray();
        }
    }

    public static Integer active() {
        return CHILDREN.size();
    }

    public static void shutdown() {
        CLOSED.set(true);
        CHILDREN.forEach(Process::destroyForcibly);
        WATCHDOG.shutdownNow();
        if (CHILDREN.isEmpty()) {
            cleanupCode();
        }
    }

    private static synchronized void cleanupCode() {
        if (bundledJar != null) {
            try {
                Files.deleteIfExists(bundledJar);
                Files.deleteIfExists(bundledJar.getParent());
            } catch (IOException e) {
                System.err.println("{\"status\":\"PDF_CODE_CLEANUP_FAILED\"}");
            }
        }
    }

    public static void dispose() {
        shutdown();
        try {
            Runtime.getRuntime().removeShutdownHook(SHUTDOWN_HOOK);
        } catch (IllegalStateException e) {
            System.err.println("{\"status\":\"RENDERER_JVM_SHUTDOWN_IN_PROGRESS\"}");
        }
    }

    private static Thread daemon(Runnable task, String name) {
        Thread thread = new Thread(task, name);
        thread.setDaemon(true);
        return thread;
    }
}
