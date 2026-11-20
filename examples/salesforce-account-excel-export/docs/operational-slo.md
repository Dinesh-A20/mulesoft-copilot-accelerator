# Operational SLOs (approval required)

No business availability, throughput, execution-latency, RTO, or RPO targets were
provided. The following are implementation limits, not approved SLOs:

- Maximum output: 50 Accounts per invocation.
- Salesforce HTTP response timeout: 30 seconds per request.
- Automatic retries: none; manual replay only after output inspection.
- Initial CloudHub footprint: one `mule.micro` replica; not an HA commitment.
- Output durability: none when using container-local storage.

Before production, the service owner must approve availability and execution SLOs,
peak invocation rate, timeout budget, RTO/RPO, file retention, recovery owner, and
destination durability. Configure Anypoint Monitoring alerts for invocation
success/failure, latency, Salesforce connectivity/auth failures, and output write
failures after target-specific thresholds are agreed.
