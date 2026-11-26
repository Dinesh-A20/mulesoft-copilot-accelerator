# salesforce-account-email-notifier

Mule 4 application that sends an email whenever a **new Account** is created in Salesforce.
Salesforce authentication uses the **OAuth 2.0 JWT Bearer** flow (no user password stored).

## How it works

| Step | Component | Behavior |
| --- | --- | --- |
| 1 | `salesforce:new-object-listener` (`objectType=Account`) | Polls every `salesforce.listener.pollFrequencySeconds` (default 60 s). The connector persists its own `CreatedDate` watermark, so each Account is emitted once. |
| 2 | `accountNotification::toNotificationAccount` | Projects only required fields (Id, Name, Phone, Billing City/Country, Industry, Type, CreatedDate in UTC). Rejects missing/invalid Ids. |
| 3 | `account-notification-sent-store` (persistent OS, 30-day TTL) | Idempotency: an Account Id already emailed is skipped. |
| 4 | `email:send` inside `until-successful` | HTML email with HTML-escaped values, CR/LF-stripped subject, and a link to the record. 3 retries, 10 s apart. |
| 5 | `account-notification-dlq-store` (persistent OS) | After retries are exhausted the notification is dead-lettered. |
| 6 | `account-notification-replay-main` | Every 15 min re-sends dead-lettered notifications and removes them only after success. |

Flows: [salesforce-account-email-notifier.xml](src/main/mule/salesforce-account-email-notifier.xml) ·
Global configs: [global-configs.xml](src/main/mule/global-configs.xml) ·
Mapping: [accountNotification.dwl](src/main/resources/dwl/accountNotification.dwl)

## 1. Salesforce setup (JWT Bearer)

1. Create a key pair and keystore (keep it **out of Git**; `*.jks` is git-ignored):
   ```bash
   keytool -genkeypair -alias salesforce-jwt -keyalg RSA -keysize 2048 -validity 365 \
     -keystore salesforce-jwt.jks -dname "CN=salesforce-account-email-notifier"
   keytool -exportcert -rfc -alias salesforce-jwt -keystore salesforce-jwt.jks -file salesforce-jwt.crt
   ```
2. In Salesforce Setup → **App Manager → New Connected App** (or External Client App):
   - Enable OAuth settings, **Use digital signatures** → upload `salesforce-jwt.crt`.
   - Scopes: `api`, `refresh_token, offline_access`.
   - Policies: *Permitted Users = Admin approved users are pre-authorized*; assign the integration user's profile/permission set.
3. Integration user needs **Read** on Account (least privilege).
4. Copy the Connected App **Consumer Key**.
5. Place the keystore at `src/main/resources/keystores/salesforce-jwt.jks` at build time (for CI, restore it from a secret before `mvn package`).

## 2. Configuration

Non-secret values: [properties/common.yaml](src/main/resources/properties/common.yaml) and `properties/<env>.yaml` (`local`, `dev`, `qa`, `prod`). Replace the placeholders:

| Property | Description |
| --- | --- |
| `salesforce.jwt.principal` | Salesforce username of the integration user |
| `salesforce.jwt.tokenEndpoint` / `audienceUrl` | `login.salesforce.com` (prod/dev org) or `test.salesforce.com` (sandbox) |
| `salesforce.instanceUrl` | My Domain URL, used for the record link in the email |
| `smtp.host`, `smtp.port`, `smtp.from` | SMTP relay (STARTTLS required, default port 587) |
| `notification.email.to` | **Your email address** (comma-separated for several recipients) |

Secrets — never put these in files; pass them as **CloudHub 2.0 secure properties** or `-D` arguments locally:

| Secure property | Value |
| --- | --- |
| `salesforce.secure.consumerKey` | Connected App consumer key |
| `salesforce.secure.keystorePassword` | Keystore password |
| `smtp.secure.username` / `smtp.secure.password` | SMTP credentials (use an app password where the provider requires it) |

## 3. Run locally

Anypoint Code Builder / Studio run configuration VM arguments:

```
-Denv=local -Dsalesforce.secure.consumerKey=... -Dsalesforce.secure.keystorePassword=... -Dsmtp.secure.username=... -Dsmtp.secure.password=...
```

Create an Account in Salesforce; within one poll interval you receive an email titled
`New Salesforce Account created: <Account Name>`.

> The listener starts from the deployment time; Accounts created before the first start are not emailed.

## 4. Build and test

```bash
mvn clean verify          # package + MUnit (coverage gate 80%)
```

MUnit suite: [salesforce-account-email-notifier-test-suite.xml](src/test/munit/salesforce-account-email-notifier-test-suite.xml).
All Salesforce, SMTP, and Object Store calls are mocked; tests use dummy values in `src/test/resources/properties/test.yaml`.

Covered scenarios: mapping (HTML escaping, UTC normalisation, nulls, header injection, subject truncation, recipient parsing, invalid Id), new Account → email sent, duplicate skipped, SMTP failure → retries → DLQ, SMTP timeout → DLQ, Object Store failure → DLQ, invalid record rejected, replay success removes entry, replay failure retains entry, empty DLQ.

## 5. Deploy to CloudHub 2.0

```bash
mvn clean deploy -DmuleDeploy \
  -Dcloudhub.environment=dev -Dcloudhub.target=<private-or-shared-space> \
  -Danypoint.clientId=$ANYPOINT_CLIENT_ID -Danypoint.clientSecret=$ANYPOINT_CLIENT_SECRET \
  -Dsalesforce.secure.consumerKey=$SF_CONSUMER_KEY -Dsalesforce.secure.keystorePassword=$SF_KEYSTORE_PASSWORD \
  -Dsmtp.secure.username=$SMTP_USERNAME -Dsmtp.secure.password=$SMTP_PASSWORD
```

- Runs as **1 replica, non-clustered** so only one poller emits each Account. Enable **Object Store v2 persistence** for the app so the dedupe/DLQ stores and connector watermark survive restarts.
- Promote the same built artifact through `dev → qa → prod`; only properties change.

## Runbook

| Symptom | Action |
| --- | --- |
| `account-notification-failed` with `SALESFORCE:*` / no events | Check JWT: consumer key, certificate uploaded to the Connected App, user pre-authorized, correct `login`/`test` endpoint, keystore alias/password. The connection reconnects 5 × every 30 s and the app keeps deploying if Salesforce is down. |
| `account-notification-failed` with `MULE:RETRY_EXHAUSTED` | SMTP unavailable/credentials invalid. Entries are kept in `account-notification-dlq-store` and replayed every 15 min automatically. |
| `account-notification-replay-failed` repeating | Fix SMTP; replay continues automatically. |
| `rejected-invalid-record` | Record without a valid Id; not replayable — investigate in Salesforce. |
| Duplicate emails | Rare: an email may be re-sent if SMTP accepted the message but the response timed out. |

Logs are structured JSON (`correlationId`, `applicationName`, `environment`, `flowName`, `accountId`, `status`, `durationMs`) under category `salesforce-account-email-notifier`; Account name/phone are never logged.

Rotate the JWT certificate by uploading the new certificate to the Connected App, redeploying with the new keystore, then removing the old certificate.
