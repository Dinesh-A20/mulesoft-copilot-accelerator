---
name: runtime-fabric-deployment
description: Designs and generates Runtime Fabric deployments for on-premises or private Kubernetes environments.
---

# Runtime Fabric Deployment

## Trigger Conditions
- Runtime Fabric is the approved private runtime.
- Cluster capacity, topology, ingress, egress, or persistence is required.

## Workflow Steps
1. Define Kubernetes cluster, namespace, ingress, egress, and availability zones.
2. Define replica, CPU, memory, persistent store, and autoscaling settings.
3. Map secret manager values and trusted certificates.
4. Configure health, monitoring, network policies, and log routing.
5. Generate deployment manifest or Maven action.
6. Define cluster drain, rollback, and recovery.

## Expected Outputs
- Runtime Fabric deployment design
- Kubernetes-facing configuration
- Security and network policy matrix
- Capacity and rollback plan

## Validation Rules
- Cluster access follows least privilege.
- Private certificates and secrets are externalized.
- Ingress, egress, and service discovery are explicit.
