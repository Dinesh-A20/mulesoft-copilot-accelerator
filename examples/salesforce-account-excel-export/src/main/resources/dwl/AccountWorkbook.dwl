%dw 2.0
import fail from dw::Runtime

var sheetName = "Accounts"

var blankRow = {
    "Account Id": "",
    "Account Name": "",
    Phone: "",
    "Billing City": ""
}

var queryFields = "SELECT Id, Name, Phone, BillingCity, LastModifiedDate FROM Account"

var salesforceIdPattern = /^[A-Za-z0-9]{15,18}$/

fun text(value) = if (value == null) "" else value as String

fun toAccountRow(account) = {
    "Account Id": text(account.Id),
    "Account Name": text(account.Name),
    Phone: text(account.Phone),
    "Billing City": text(account.BillingCity)
}

fun normalizeRow(row) = {
    "Account Id": text(row."Account Id"),
    "Account Name": text(row."Account Name"),
    Phone: text(row.Phone),
    "Billing City": text(row."Billing City")
}

// Rows without an Account Id (including the empty-workbook placeholder) are not data rows.
fun existingAccountRows(workbook) =
    ((workbook default {})[sheetName] default [])
        map normalizeRow($)
        filter (row) -> !isEmpty(trim(row."Account Id"))

// Salesforce returns DateTime values from the connector, or ISO strings such as
// 2026-11-20T05:00:00.000+0000 in some serializations.
fun toUtcDateTime(value): DateTime =
    if (value is DateTime) (value as DateTime) >> |+00:00|
    else if (value is String) do {
        var normalized = (value as String) replace /([+-]\d{2})(\d{2})$/ with ("$($[1]):$($[2])")
        ---
        (normalized as DateTime) >> |+00:00|
    }
    else fail("Unsupported Salesforce LastModifiedDate value")

fun soqlDateTime(value) = toUtcDateTime(value) as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}

fun validId(id) =
    if ((text(id)) matches salesforceIdPattern) text(id)
    else fail("Invalid export watermark Account Id")

fun parseWatermark(stored) = do {
    var watermark = if (isEmpty(stored)) {} else read(stored as String, "application/json")
    ---
    if (watermark.lastModifiedDate == null) null
    else { lastModifiedDate: soqlDateTime(watermark.lastModifiedDate), id: validId(watermark.id) }
}

// The watermark only applies when the workbook already holds a baseline; a missing or
// emptied workbook triggers a fresh initial load instead of silently skipping history.
fun effectiveWatermark(workbook, stored) =
    if (isEmpty(existingAccountRows(workbook))) null else parseWatermark(stored)

// Keyset pagination on (LastModifiedDate, Id) so Accounts sharing a timestamp across
// the 50-record boundary are neither skipped nor fetched forever.
fun buildAccountQuery(watermark) =
    if (watermark == null)
        queryFields ++ " ORDER BY LastModifiedDate DESC, Id DESC LIMIT 50"
    else do {
        var since = soqlDateTime(watermark.lastModifiedDate)
        var lastId = validId(watermark.id)
        ---
        queryFields ++ " WHERE LastModifiedDate > $(since) OR (LastModifiedDate = $(since) AND Id > '$(lastId)')"
            ++ " ORDER BY LastModifiedDate ASC, Id ASC LIMIT 50"
    }

fun nextWatermark(accounts, previous) =
    if (isEmpty(accounts)) previous
    else do {
        var newest = if (previous == null) accounts[0] else accounts[-1]
        ---
        { lastModifiedDate: soqlDateTime(newest.LastModifiedDate), id: validId(newest.Id) }
    }

fun mergeAccounts(workbook, accounts) = do {
    var source = if (accounts is Array) accounts
                 else fail("Salesforce query did not return an Account array")
    var existingRows = existingAccountRows(workbook)
    var incomingRows = source map toAccountRow($)
    var incomingById = {(incomingRows map (row) -> {(row."Account Id"): row})}
    var existingIds = {(existingRows map (row) -> {(row."Account Id"): true})}
    var mergedExisting = existingRows map (row) -> (incomingById[row."Account Id"] default row)
    var appendedRows = incomingRows filter (row) -> existingIds[row."Account Id"] == null
    var updatedRows = existingRows filter (row) -> do {
        var incoming = incomingById[row."Account Id"]
        ---
        incoming != null and incoming != row
    }
    ---
    {
        rows: mergedExisting ++ appendedRows,
        inserted: sizeOf(appendedRows),
        updated: sizeOf(updatedRows)
    }
}
