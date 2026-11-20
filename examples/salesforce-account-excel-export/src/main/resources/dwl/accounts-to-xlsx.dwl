%dw 2.0
import blankRow from dwl::AccountWorkbook
output application/xlsx header=true
var rows = vars.mergeResult.rows default []
---
{
    Accounts: if (isEmpty(rows)) [blankRow] else rows
}
