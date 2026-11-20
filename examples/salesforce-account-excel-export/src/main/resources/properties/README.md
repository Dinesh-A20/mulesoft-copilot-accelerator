# Salesforce JWT runtime configuration

The application intentionally does not package a Salesforce keystore or credentials.
Configure the Connected App consumer key and keystore password through CloudHub 2.0
secure application properties or an approved local secret provider:

- `salesforce.secure.jwt.consumer-key`
- `salesforce.secure.jwt.keystore-password`

Provide the corresponding keystore file at the externally managed path configured by
`salesforce.jwt.keystore.path`. The keystore contains the private key used to sign JWTs;
do not commit it, package it in the application, or place it in test resources. Mount or
retrieve it at runtime through an organization-approved secret/file delivery mechanism,
with access restricted to the Mule runtime identity. Configure
`salesforce.jwt.certificate-alias`, `salesforce.jwt.principal`, and
`salesforce.jwt.token-endpoint` per environment.

Never put private keys, keystore passwords, live credentials, or tokens in
`config.yaml`, source control, Maven command-line arguments, logs, or test fixtures.
The Salesforce Connected App must trust the matching public certificate and authorize
an integration user with read-only access to the four selected Account fields. Configure
the JWT signing certificate with `SHA256withRSA`; keep the private key in the keystore
under the approved rotation and access-control process.
