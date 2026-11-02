# Setup guide

This project uses Jenkins, a remote Docker build host, an Ansible controller, an EKS management host, Docker Hub, and an Amazon EKS cluster. Configure account-specific values in the relevant systems; keep them out of Git.

## Prerequisites

- Java 21 and Maven 3.10.0 configured as Jenkins tools
- Jenkins Pipeline, Git, SSH Agent, and Credentials Binding support
- A Jenkins agent with Git, SSH/SCP, and Maven available
- A remote Docker host with Docker Engine and SSH access from Jenkins and Ansible
- An Ansible controller with Ansible installed and SSH access to both inventory groups
- An EKS management host with AWS CLI, `kubectl`, `eksctl`, AWS IAM role access, and kubeconfig
- Docker Hub repository and Jenkins-managed credentials

## Jenkins credentials and job configuration

Create Jenkins credentials for the Docker build host SSH key, Ansible controller SSH key, and Docker Hub username/token. Use credential IDs in the pipeline; never insert values in source. Configure the GitHub webhook to trigger the Jenkins job using the plugin and trigger mode installed in the environment.

The pipeline references Java/Maven tool names and remote project directories configured for the original Jenkins environment. Replace these with your own Jenkins tool and host configuration when reproducing the project.

## Ansible setup

Place `ansible.cfg`, `inventory.ini`, and `deploy.yml` in the Ansible project directory configured in Jenkins. Use the private inventory for real host addresses and key paths. For a public repository, publish only an example inventory with placeholders and safe host aliases.

The EKS host must have an IAM role that permits the required EKS authentication and Kubernetes actions. Configure its kubeconfig for the deployment user and verify `kubectl cluster-info` before using Jenkins.

## Build the application

From the repository root:

```bash
mvn -B -ntp clean package
```

The WAR module's final name is `webapp`, producing `webapp/target/webapp.war`. The Jenkins pipeline searches for the first WAR under a module `target` directory and transfers it as `app.war`.

## Create and scale the EKS cluster

Use a sanitized `eksctl` ClusterConfig with your chosen cluster name and region. Validate the configuration with `eksctl create cluster -f <config> --dry-run` before creating resources. The sample environment started with zero workers and scaled the managed node group to two before deploying the application.

The sample used a public API endpoint and public LoadBalancer Service. Understand the AWS cost and access implications before creating resources in your account.

## Deployment verification

Ansible checks cluster connectivity, updates the image, waits for rollout, and verifies two ready replicas. To inspect the service endpoint in your own cluster, use:

```bash
kubectl get service hello-world-service
```

Do not add a current LoadBalancer hostname to static docs unless you intend to maintain a public demo. Do not commit kubeconfig files, private keys, or shell output containing credentials.

