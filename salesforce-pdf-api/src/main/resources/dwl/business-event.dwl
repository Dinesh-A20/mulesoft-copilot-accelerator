%dw 2.0
output application/java
---
{
  schemaVersion: "1.0",
  eventId: uuid(),
  eventType: vars.businessEvent,
  timestamp: (now() >> |+00:00|) as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"},
  correlationId: vars.requestCorrelation,
  transactionId: vars.transactionId,
  apiName: p("application.name"),
  status: if (vars.businessEvent == "PDF_FAILED") "FAILED" else "SUCCESS",
  processingTimeMs: (now() as Number {unit: "milliseconds"}) - vars.startedMs,
  (errorCode: vars.errorInfo.errorCode) if (vars.businessEvent == "PDF_FAILED"),
  (pdfBytes: vars.pdfBytes) if (vars.businessEvent == "PDF_GENERATED")
}
