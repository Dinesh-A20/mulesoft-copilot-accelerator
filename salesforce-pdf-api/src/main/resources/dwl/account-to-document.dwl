%dw 2.0
import model from dwl::AccountDocument
output application/java
---
model(vars.account, vars.generatedTimestamp, vars.requestCorrelation)
