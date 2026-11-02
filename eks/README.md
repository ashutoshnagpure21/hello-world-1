# Amazon EKS setup

The project uses an eksctl ClusterConfig and a managed node group. The example keeps the cluster name and region generic; set them for your own AWS account before use. The supplied project configuration used a managed `t3.medium` node group, 20 GiB worker volumes, zero initial nodes, and autoscaling bounds of zero to three. The group was scaled to two nodes for application deployment.

## Create and connect

```bash
eksctl create cluster -f cluster.example.yaml --dry-run
eksctl create cluster -f cluster.example.yaml
aws eks update-kubeconfig --region YOUR_AWS_REGION --name your-hello-world-cluster
kubectl cluster-info
kubectl get nodes
```

The management host authenticates through an attached IAM role and a user-specific kubeconfig. Use least-privilege permissions and restrict Kubernetes API access in production. Do not commit kubeconfig files, account IDs, role ARNs, private network ranges, or access keys.

## Scale the managed node group

```bash
eksctl scale nodegroup --cluster your-hello-world-cluster --name hello-world-workers --region YOUR_AWS_REGION --nodes 2 --nodes-min 0 --nodes-max 3 --wait
```

Scaling workers to zero does not remove the EKS control plane, NAT Gateway, management instance, or all networking resources. Review ongoing AWS charges. For complete cleanup, verify each project resource before deleting the cluster and associated resources.
