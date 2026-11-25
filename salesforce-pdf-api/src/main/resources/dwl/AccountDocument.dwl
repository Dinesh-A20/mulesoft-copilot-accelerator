%dw 2.0
import try from dw::Runtime

fun blank(value) = value == null or (value is String and isEmpty(trim(value)))
fun display(value) = if (blank(value)) "N/A" else value as String
fun revenue(value) = if (value == null) 0 else value as Number
fun utc(value) =
  if (blank(value)) "N/A"
  else ((value as DateTime) >> |+00:00|) as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}
fun mandatoryValid(account) =
  account is Object and account.Id is String and account.Name is String and
  not blank(account.Id) and not blank(account.Name)
fun optionalValid(account) =
  try(() -> revenue(account.AnnualRevenue)).success and
  try(() -> utc(account.LastModifiedDate)).success
fun escape(value) =
  ((((value as String) replace "&" with "&amp;")
    replace "<" with "&lt;") replace ">" with "&gt;")
    replace "\"" with "&quot;"
fun model(account, generated, correlation) = {
  accountId: account.Id as String,
  accountName: account.Name as String,
  accountType: display(account.Type),
  industry: display(account.Industry),
  phone: display(account.Phone),
  website: display(account.Website),
  billingCity: display(account.BillingCity),
  billingCountry: display(account.BillingCountry),
  annualRevenue: revenue(account.AnnualRevenue) as String {format: "0.################"},
  lastModifiedDate: utc(account.LastModifiedDate),
  generatedTimestamp: utc(generated),
  correlationId: correlation
}
fun html(template, values) =
  (values pluck ((value, key) -> {token: "{{" ++ (key as String) ++ "}}", value: escape(value)}))
    reduce ((entry, result = template) -> result replace entry.token with entry.value)
