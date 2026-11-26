%dw 2.0
import fail from dw::Runtime
import repeat from dw::core::Strings
import every from dw::core::Arrays

// FR-35, DR-30: describe returns only fields accessible to the integration identity.
fun fieldsFrom(schema) =
    if (not (schema.fields is Array) or isEmpty(schema.fields))
        fail("Opportunity field metadata is missing.")
    else do {
        var fields = schema.fields orderBy $.name
        ---
        if (not (fields every ((field) -> field.name is String and
                (field.name matches /^[A-Za-z_][A-Za-z0-9_]*$/))) or
            sizeOf(fields distinctBy $.name) != sizeOf(fields) or
            not ((fields map $.name) contains "Id") or
            not ((fields map $.name) contains "LastModifiedDate"))
            fail("Opportunity field metadata is invalid.")
        else fields
    }

fun queryFor(fields, cutoff: DateTime) =
    "SELECT " ++ ((fields map $.name) joinBy ", ") ++
    " FROM Opportunity WHERE LastModifiedDate >= " ++
    ((cutoff >> |+00:00|) as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}) ++
    " ORDER BY Id"

fun normalizeOffset(value: String) =
    value replace /([+-]\d{2})(\d{2})$/ with ((groups) -> groups[1] ++ ":" ++ groups[2])

fun cell(value, field) =
    if (value == null or value == "") ""
    else if (value is Object or value is Array)
        write(value, "application/json", {indent: false})
    else do {
        var kind = lower(field.fieldType as String)
        ---
        if (["currency", "double", "percent", "int", "long"] contains kind)
            (value as Number) as String {format: ("0." ++ repeat("#", 340)), locale: "en"}
        else if (kind == "datetime")
            ((normalizeOffset(value as String) as DateTime) >> |+00:00|)
                as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"}
        else if (kind == "date")
            (value as Date) as String {format: "yyyy-MM-dd"}
        else value as String
    }

fun row(record, fields) =
    if (not (record is Object) or not (record.Id is String) or
        not (record.Id matches /^006[A-Za-z0-9]{12}([A-Za-z0-9]{3})?$/))
        fail("Opportunity record identity is invalid.")
    else fields reduce ((field, result = {}) ->
        result ++ {(field.name): cell(record[field.name], field)})
