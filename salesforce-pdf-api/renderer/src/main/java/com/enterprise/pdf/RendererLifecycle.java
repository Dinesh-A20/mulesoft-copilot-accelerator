package com.enterprise.pdf;

import java.io.IOException;

/** CON-06: Mule's Spring context owns warmup and application-disposal cleanup. */
public final class RendererLifecycle implements AutoCloseable {
    public void initialize() throws IOException {
        try {
            IsolatedRenderer.rendererJar();
        } catch (IOException | PdfFailure e) {
            IsolatedRenderer.dispose();
            throw e;
        }
    }

    @Override
    public void close() {
        IsolatedRenderer.dispose();
    }
}
