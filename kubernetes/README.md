# Kubernetes manifests

The Deployment runs two application replicas and uses a RollingUpdate strategy. The Service selects pods with `app=hello-world` and exposes port 80, forwarding traffic to container port 8080.

Before applying the Deployment, replace `your-dockerhub-namespace` with the namespace that owns the published image. During automated deployment, Ansible updates the image tag to the Jenkins build number.

Apply and inspect from a configured cluster context:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/hello-world-deployment --timeout=300s
kubectl get deployments,pods,services
```

A `LoadBalancer` Service provisions a cloud load balancer and can incur ongoing charges. The generated hostname is dynamic and is not stored in this repository.
