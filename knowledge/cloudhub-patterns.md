# CloudHub Patterns

## Runtime
Pin Mule runtime patch and JDK-compatible versions. Separate application artifact from environment configuration.

## Availability
Choose replica count and CPU/memory based on measured concurrency. Use HA and autoscaling for variable workloads.

## State
Use persistent Object Store only for required recovery. Externalize business state and do not assume local disk or worker affinity.

## Networking
Use private space, VPC, load balancing, DLB, VPN/TGW, ingress controls, and private DNS as required.

## Operations
Configure tracing, custom metrics, alarms, log retention, smoke checks, rollback, and replay.
