package com.enterprise.pdf;

public final class PdfFailure extends RuntimeException {
    private final String code;

    public PdfFailure(String code) {
        super(code);
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
