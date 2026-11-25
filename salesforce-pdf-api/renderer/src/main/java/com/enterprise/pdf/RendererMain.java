package com.enterprise.pdf;

import com.openhtmltopdf.outputdevice.helper.ExternalResourceControlPriority;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.openhtmltopdf.util.XRLog;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

/** DR-12, SEC-06: pipe-only input/output; this initial template needs no external assets. */
public final class RendererMain {
    private RendererMain() {}

    public static void main(String[] args) {
        XRLog.setLoggingEnabled(false);
        int exit = 0;
        try {
            String html = new String(IsolatedRenderer.boundedRead(System.in), StandardCharsets.UTF_8);
            byte[] pdf = render(html);
            System.out.write(pdf);
            System.out.flush();
        } catch (PdfFailure e) {
            exit = "PDF_SIZE_EXCEEDED".equals(e.getCode()) ? 3 : 2;
        } catch (Exception e) {
            exit = 2;
        }
        if (exit != 0) {
            // Binary protocol uses exit codes, not confidential renderer diagnostics.
            System.exit(exit);
        }
    }

    static byte[] render(String html) throws Exception {
        XRLog.setLoggingEnabled(false);
        ByteArrayOutputStream result = new ByteArrayOutputStream();
        OutputStream bounded = new OutputStream() {
            @Override
            public void write(int value) throws IOException {
                if (result.size() >= 2 * 1024 * 1024) {
                    throw new PdfFailure("PDF_SIZE_EXCEEDED");
                }
                result.write(value);
            }
            @Override
            public void write(byte[] bytes, int offset, int length) throws IOException {
                if (result.size() + length > 2 * 1024 * 1024) {
                    throw new PdfFailure("PDF_SIZE_EXCEEDED");
                }
                result.write(bytes, offset, length);
            }
        };
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.useFont(() -> RendererMain.class.getResourceAsStream(
                "/org/apache/pdfbox/resources/ttf/LiberationSans-Regular.ttf"), "report-font");
        builder.useExternalResourceAccessControl((uri, type) -> false,
                ExternalResourceControlPriority.RUN_BEFORE_RESOLVING_URI);
        builder.useExternalResourceAccessControl((uri, type) -> false,
                ExternalResourceControlPriority.RUN_AFTER_RESOLVING_URI);
        builder.withHtmlContent(html, null);
        builder.toStream(bounded);
        builder.run();
        return result.toByteArray();
    }
}
