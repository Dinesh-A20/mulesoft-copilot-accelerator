package com.enterprise.pdf;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.text.PDFTextStripper;
import org.junit.jupiter.api.Test;
import java.nio.file.Path;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.concurrent.*;
import java.util.jar.*;
import org.junit.jupiter.api.io.TempDir;
import static org.junit.jupiter.api.Assertions.*;

class ChildRendererIT {
    @TempDir Path temporary;

    private String javaExecutable() {
        String binary = System.getProperty("os.name").startsWith("Windows") ? "java.exe" : "java";
        return Path.of(System.getProperty("java.home"), "bin", binary).toString();
    }

    @Test
    void packagedChildReturnsInspectablePdfWithoutDocumentFiles() throws Exception {
        byte[] pdf = IsolatedRenderer.render("<html><body>Account Summary Report</body></html>",
                javaExecutable(), System.getProperty("renderer.jar"), RuntimeSupport.deadline());
        try (var document = Loader.loadPDF(pdf)) {
            assertTrue(new PDFTextStripper().getText(document).contains("Account Summary Report"));
        }
    }

    @Test
    void expiredDeadlineDoesNotStartChild() {
        PdfFailure failure = assertThrows(PdfFailure.class, () -> IsolatedRenderer.render(
                "<html/>", javaExecutable(), System.getProperty("renderer.jar"), System.nanoTime() - 1));
        assertEquals("TIMEOUT", failure.getCode());
        assertEquals(0, IsolatedRenderer.active());
    }

    @Test
    void timeoutKillsUnresponsiveOwnedProcessAndReleasesCapacity() throws Exception {
        String jar = unresponsiveJar();
        long start = System.nanoTime();
        PdfFailure failure = assertThrows(PdfFailure.class, () -> IsolatedRenderer.render(
                "<html/>", javaExecutable(), jar, System.nanoTime() + TimeUnit.MILLISECONDS.toNanos(300)));
        assertEquals("TIMEOUT", failure.getCode());
        assertTrue(TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - start) < 2000);
        awaitNoChildren();
    }

    @Test
    void sixthLiveRenderFailsFastWithoutStartingAnotherChild() throws Exception {
        String jar = unresponsiveJar();
        ExecutorService callers = Executors.newFixedThreadPool(5);
        var futures = new ArrayList<Future<?>>();
        try {
            for (int i = 0; i < 5; i++) {
                futures.add(callers.submit(() -> assertThrows(PdfFailure.class,
                        () -> IsolatedRenderer.render("<html/>", javaExecutable(), jar, RuntimeSupport.deadline()))));
            }
            long limit = System.nanoTime() + TimeUnit.SECONDS.toNanos(3);
            while (IsolatedRenderer.active() < 5 && System.nanoTime() < limit) {
                Thread.sleep(10);
            }
            assertEquals(5, IsolatedRenderer.active());
            long start = System.nanoTime();
            PdfFailure failure = assertThrows(PdfFailure.class, () -> IsolatedRenderer.render(
                    "<html/>", javaExecutable(), jar, RuntimeSupport.deadline()));
            assertEquals("CAPACITY_EXCEEDED", failure.getCode());
            assertTrue(TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - start) < 500);
            for (Future<?> future : futures) {
                future.get(8, TimeUnit.SECONDS);
            }
            awaitNoChildren();
        } finally {
            callers.shutdownNow();
        }
    }

    private String unresponsiveJar() throws Exception {
        Manifest manifest = new Manifest();
        manifest.getMainAttributes().put(Attributes.Name.MANIFEST_VERSION, "1.0");
        manifest.getMainAttributes().put(Attributes.Name.MAIN_CLASS, UnresponsiveChild.class.getName());
        Path jar = temporary.resolve("unresponsive-test.jar");
        String entry = "com/enterprise/pdf/UnresponsiveChild.class";
        try (var output = new JarOutputStream(Files.newOutputStream(jar), manifest);
             var source = UnresponsiveChild.class.getResourceAsStream("/" + entry)) {
            assertNotNull(source);
            output.putNextEntry(new JarEntry(entry));
            source.transferTo(output);
            output.closeEntry();
        }
        return jar.toString();
    }

    private void awaitNoChildren() throws Exception {
        long limit = System.nanoTime() + TimeUnit.SECONDS.toNanos(2);
        while (IsolatedRenderer.active() != 0 && System.nanoTime() < limit) {
            Thread.sleep(10);
        }
        assertEquals(0, IsolatedRenderer.active());
    }
}
