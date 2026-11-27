# Generated Project Checklist

- [ ] Requirements and assumptions are traceable.
- [ ] API-led architecture and API ownership are documented.
- [ ] RAML and examples validate.
- [ ] Maven project builds reproducibly.
- [ ] One authored `src/main/mule` per app. New and changed XML uses `main/`, `implementation/`, or `config/` according to its responsibility; generated build copies are not source roots.
- [ ] Every connector source, operation and Logger has an action-specific Studio `doc:name`; shared behavior is extracted by capability and the entry-to-implementation path is tested with only external boundaries mocked.
- [ ] Secure properties and TLS are configured.
- [ ] No credentials or private values are source-controlled.
- [ ] DataWeave mappings cover null, date, and boundary cases.
- [ ] MUnit success, negative, timeout, retry, and replay cases exist.
- [ ] Streaming, pagination, batching, pooling, caching, and retry limits are suitable.
- [ ] CI build, test, security, and deployment gates exist.
- [ ] Health, metrics, logs, alerts, rollback, and replay are documented.
