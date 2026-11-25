package com.enterprise.pdf;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.text.PDFTextStripper;
import org.junit.jupiter.api.Test;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import static org.junit.jupiter.api.Assertions.*;

class RendererTest {
    @Test
    void escapedAccountTextIsPdfTextAndOverflowPaginates() throws Exception {
        String html = "<html><body><h1>Account Summary Report</h1><p>Acme &lt;script&gt; &amp; Company</p>"
                + "<div style='page-break-before:always'>Audit Information</div></body></html>";
        try (var document = Loader.loadPDF(RendererMain.render(html))) {
            assertEquals(2, document.getNumberOfPages());
            String text = new PDFTextStripper().getText(document);
            assertTrue(text.contains("Acme <script> & Company"));
            assertTrue(text.contains("Audit Information"));
        }
    }

    @Test
    void packagedFontPreservesAccentedAccountNames() throws Exception {
        String html = "<html><head><style>body { font-family: report-font; }</style></head>"
                + "<body>Caf\u00e9 Corporation</body></html>";
        try (var document = Loader.loadPDF(RendererMain.render(html))) {
            assertTrue(new PDFTextStripper().getText(document).contains("Caf\u00e9 Corporation"));
        }
    }

    @Test
    void remoteAndFileAssetsAreNotLoaded() throws Exception {
        String html = "<html><body><p>Account Summary Report</p>"
                + "<img src='http://127.0.0.1:1/private'/>"
                + "<img src='file:///nonexistent/confidential.png'/></body></html>";
        byte[] bytes = RendererMain.render(html);
        assertEquals("%PDF-", new String(bytes, 0, 5, StandardCharsets.US_ASCII));
    }

    @Test
    void outputIsMeasuredAndOverTwoMegabytesIsRejected() {
        byte[] oversized = new byte[2 * 1024 * 1024 + 1];
        PdfFailure failure = assertThrows(PdfFailure.class,
                () -> IsolatedRenderer.boundedRead(new ByteArrayInputStream(oversized)));
        assertEquals("PDF_SIZE_EXCEEDED", failure.getCode());
    }

    @Test
    void deadlineAndUnsafeCorrelationAreEnforced() {
        PdfFailure failure = assertThrows(PdfFailure.class,
                () -> RuntimeSupport.requireBudget(System.nanoTime() - 1, 1L));
        assertEquals("TIMEOUT", failure.getCode());
        assertEquals("safe-123", RuntimeSupport.correlation("safe-123"));
        assertTrue(RuntimeSupport.correlation("injected\r\nheader").matches("[A-Za-z0-9._-]{1,64}"));
    }

    @Test
    void publisherAdmissionDoesNotQueueAndReleaseIsIdempotent() {
        String[] leases = new String[5];
        try {
            for (int i = 0; i < leases.length; i++) {
                leases[i] = RuntimeSupport.acquirePublisher(RuntimeSupport.deadline());
                assertFalse(leases[i].isEmpty());
            }
            assertEquals("", RuntimeSupport.acquirePublisher(RuntimeSupport.deadline()));
            RuntimeSupport.releasePublisher(leases[0]);
            RuntimeSupport.releasePublisher(leases[0]);
            leases[0] = RuntimeSupport.acquirePublisher(RuntimeSupport.deadline());
            assertFalse(leases[0].isEmpty());
            assertEquals("", RuntimeSupport.acquirePublisher(RuntimeSupport.deadline()));
        } finally {
            for (String lease : leases) {
                if (lease != null) RuntimeSupport.releasePublisher(lease);
            }
        }
    }
}
