%dw 2.0
import row from dwl::OpportunityCsv
import fail from dw::Runtime
output application/csv header=false, encoding="UTF-8", lineSeparator="\r\n"
---
if (not (payload is Array)) fail("Opportunity batch must be an array.")
else payload map ((record) -> row(record, vars.etlFields))
