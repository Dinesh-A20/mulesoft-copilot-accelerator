%dw 2.0
output application/json
---
{
  timestamp: (now() >> |+00:00|) as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"},
  correlationId: vars.requestCorrelation,
  transactionId: vars.transactionId,
  apiName: p("application.name"),
  applicationName: p("application.name"),
  environment: p("mule.env"),
  flowName: vars.logFlow,
  source: vars.logSource default "mule",
  status: vars.logStatus,
  eventType: vars.businessEvent default null,
  processingTimeMs: (now() as Number {unit: "milliseconds"}) - vars.startedMs,
  requestMetadata: {method: vars.requestMethod, route: vars.routeTemplate},
  responseMetadata: {
    statusCode: vars.httpStatus default null,
    mediaType: vars.responseMediaType default null,
    byteCount: vars.responseBytes default null
  },
  errorCode: vars.errorInfo.errorCode default null
}
