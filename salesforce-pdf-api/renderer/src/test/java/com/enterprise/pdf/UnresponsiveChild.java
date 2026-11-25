package com.enterprise.pdf;

/** Test-only child fixture; never included in production renderer artifacts. */
public final class UnresponsiveChild {
    public static void main(String[] args) throws Exception {
        System.in.readAllBytes();
        for (;;) {
            Thread.sleep(1000);
        }
    }
}
