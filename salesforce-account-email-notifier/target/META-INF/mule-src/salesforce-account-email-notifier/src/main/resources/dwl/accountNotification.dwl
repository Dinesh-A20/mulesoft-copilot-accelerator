%dw 2.0
import fail, try, orElse from dw::Runtime

var salesforceIdPattern = /^[a-zA-Z0-9]{15,18}$/
var maxSubjectNameLength = 120

fun isBlankValue(value: Any): Boolean =
    value == null or trim(value as String) == ""

fun textOrNull(value: Any): String | Null =
    if (isBlankValue(value)) null else trim(value as String)

// Salesforce returns DateTime/Calendar values; normalise to ISO-8601 UTC. Unparseable values are passed through as text.
fun toUtcText(value: Any): String | Null =
    if (isBlankValue(value)) null
    else try(() -> ((value as DateTime) >> "UTC") as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"})
        orElse (value as String)

fun escapeHtml(text: String): String =
    ((((text replace "&" with "&amp;")
        replace "<" with "&lt;")
        replace ">" with "&gt;")
        replace "\"" with "&quot;")
        replace "'" with "&#39;"

fun displayHtml(value: Any): String =
    if (isBlankValue(value)) "-" else escapeHtml(value as String)

// Strip CR/LF so the Account name can never inject extra mail headers.
fun toSubject(name: String | Null): String = do {
    var safeName = ((name default "Unnamed Account") replace /[\r\n\t]+/ with " ")
    var shortName = if (sizeOf(safeName) > maxSubjectNameLength) safeName[0 to maxSubjectNameLength - 1] ++ "..." else safeName
    ---
    "New Salesforce Account created: " ++ shortName
}

// Projects the Salesforce listener record to the minimal, serializable notification model.
fun toNotificationAccount(record: Object): Object = do {
    var id = textOrNull(record.Id)
    ---
    if (id == null or not (id matches salesforceIdPattern))
        fail("Invalid or missing Salesforce Account Id")
    else {
        id: id,
        name: textOrNull(record.Name),
        phone: textOrNull(record.Phone),
        billingCity: textOrNull(record.BillingCity),
        billingCountry: textOrNull(record.BillingCountry),
        industry: textOrNull(record.Industry),
        accountType: textOrNull(record.Type),
        createdDate: toUtcText(record.CreatedDate)
    }
}

fun toRecipients(csv: String | Null): Array<String> = do {
    var recipients = ((csv default "") splitBy ",") map trim($) filter ($ != "")
    ---
    if (isEmpty(recipients)) fail("notification.email.to must contain at least one recipient") else recipients
}

fun recordUrl(instanceUrl: String, id: String): String =
    (instanceUrl replace /\/+$/ with "") ++ "/lightning/r/Account/" ++ id ++ "/view"

fun buildEmail(account: Object, instanceUrl: String): Object = do {
    var url = recordUrl(instanceUrl, account.id)
    var rows = [
        ["Account Name", account.name],
        ["Account Id", account.id],
        ["Phone", account.phone],
        ["Billing City", account.billingCity],
        ["Billing Country", account.billingCountry],
        ["Industry", account.industry],
        ["Type", account.accountType],
        ["Created (UTC)", account.createdDate]
    ]
    ---
    {
        subject: toSubject(account.name),
        body: "<html><body style=\"font-family:Arial,sans-serif\">"
            ++ "<h3>A new Account was created in Salesforce</h3>"
            ++ "<table border=\"1\" cellpadding=\"6\" cellspacing=\"0\" style=\"border-collapse:collapse\">"
            ++ (rows map ("<tr><th align=\"left\">" ++ $[0] ++ "</th><td>" ++ displayHtml($[1]) ++ "</td></tr>") joinBy "")
            ++ "</table>"
            ++ "<p><a href=\"" ++ escapeHtml(url) ++ "\">Open the Account in Salesforce</a></p>"
            ++ "</body></html>"
    }
}
