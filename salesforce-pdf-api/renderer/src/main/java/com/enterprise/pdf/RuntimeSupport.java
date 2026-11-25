package com.enterprise.pdf;

import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

/** FR-12, FR-24, ERR-07, ERR-21: monotonic budgets and non-queued publisher admission. */
public final class RuntimeSupport {
    private static final Semaphore PUBLISHERS = new Semaphore(5);
    private static final Set<String> LEASES = ConcurrentHashMap.newKeySet();

    private RuntimeSupport() {}

    public static Long deadline() {
        return System.nanoTime() + TimeUnit.SECONDS.toNanos(20);
    }

    public static Long renderDeadline(Long overallDeadline) {
        return Math.min(overallDeadline, System.nanoTime() + TimeUnit.SECONDS.toNanos(5));
    }

    public static Long remainingMillis(Long deadline) {
        return Math.max(0L, TimeUnit.NANOSECONDS.toMillis(deadline - System.nanoTime()));
    }

    public static void requireBudget(Long deadline, Long millis) {
        if (millis <= 0 || remainingMillis(deadline) < millis) {
            throw new PdfFailure("TIMEOUT");
        }
    }

    public static void pause(Long deadline, Long millis) throws InterruptedException {
        requireBudget(deadline, millis + 1);
        TimeUnit.MILLISECONDS.sleep(millis);
        requireBudget(deadline, 1L);
    }

    public static String correlation(String supplied) {
        return supplied != null && supplied.matches("[A-Za-z0-9._-]{1,64}")
                ? supplied : UUID.randomUUID().toString();
    }

    public static String acquirePublisher(Long deadline) {
        if (remainingMillis(deadline) < 6000 || !PUBLISHERS.tryAcquire()) {
            return "";
        }
        String lease = UUID.randomUUID().toString();
        LEASES.add(lease);
        return lease;
    }

    public static void releasePublisher(String lease) {
        if (LEASES.remove(lease)) {
            PUBLISHERS.release();
        }
    }

    public static String errorCode(Throwable cause) {
        for (int depth = 0; cause != null && depth < 12; depth++, cause = cause.getCause()) {
            if (cause instanceof PdfFailure failure) {
                return failure.getCode();
            }
        }
        return "INTERNAL_ERROR";
    }
}
