%dw 2.0
import html from dwl::AccountDocument
output text/plain
---
html(readUrl("classpath://templates/account-summary.html", "text/plain"), vars.document)
