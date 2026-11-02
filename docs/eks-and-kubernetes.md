# Amazon EKS and Kubernetes

## Cluster configuration

The shared `eksctl` ClusterConfig provisions an EKS cluster and managed node group. Account-specific values are represented generically here.

| Setting | Project configuration |
| --- | --- |
| Cluster | `<EKS_CLUSTER_NAME>` |
| Region | `<AWS_REGION>` |
| Kubernetes version | `1.36` as recorded in the supplied project configuration |
| Node group | `<NODE_GROUP_NAME>` |
| Instance type | `t3.medium` |
| Initial desired nodes | `0` |
| Autoscaling range | `0` to `3` |
| Worker volume | `20 GiB` |
| Node label | `role=worker` |

The node group was scaled to two workers before the application deployment and can be scaled to zero during idle periods. The EKS control plane, NAT Gateway, and other networking resources may continue to incur charges when worker count is zero.

The project notes report a public Kubernetes API endpoint and disabled private endpoint. For production, restrict API access to trusted networks and use least-privilege IAM permissions.

## EKS management host

A dedicated EC2 management host runs AWS CLI, `kubectl`, and `eksctl`. It is not a Kubernetes master node. AWS operates the EKS control plane. The management host receives AWS credentials through an attached IAM role and uses a user-specific kubeconfig to access the cluster.

The source notes report an administrative lab role. Replace it with a least-privilege role before using this pattern outside a learning environment.

## Application Deployment

The Deployment is named `hello-world-deployment`, runs in `default`, and has two replicas. Its pod label is `app=hello-world`, and its container is `hello-world-container` on port 8080. The image is `<DOCKERHUB_NAMESPACE>/hello-world:<BUILD_NUMBER>`.

The deployment strategy uses `maxSurge: 1` and `maxUnavailable: 0`. A TCP readiness probe checks port 8080 after a 10-second initial delay and every 10 seconds. Resource requests are 100m CPU and 256Mi memory; limits are 500m CPU and 512Mi memory.

The Service is `hello-world-service`, type `LoadBalancer`, and selects `app=hello-world`. It exposes TCP port 80 and forwards to target port 8080. AWS provisions a public load balancer for this Service; the hostname is dynamic and is intentionally omitted from the portfolio docs.

## Rollout verification

Ansible runs `kubectl rollout status` with a 300-second timeout and waits for two ready replicas with a 120-second timeout. It then displays the Deployment and matching pods. Two replicas do not by themselves guarantee that Kubernetes places pods on separate worker nodes; topology spread or anti-affinity can be added if that resilience is a project goal.

## Cost and cleanup

Scaling the node group to zero reduces worker compute use but does not remove the EKS control plane, NAT Gateway, management EC2 instance, or all networking resources. Deleting the LoadBalancer Service should request cleanup of its associated AWS load balancer. For full teardown, review all project resources and confirm they are no longer needed before deletion.

## Manifest alignment

The published `kubernetes/` examples use the actual Deployment, Service, labels, container, ports, and resource settings shared for this deployment. The image namespace is a placeholder and must be replaced by the image publisher.

