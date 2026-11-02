# Java CI/CD Pipeline on Amazon EKS

A learning project that automates delivery of a Java web application to Amazon EKS. Jenkins builds and tests the Maven application, packages a WAR, builds a Docker image on a remote host, and invokes Ansible to publish a versioned image and roll it out to Kubernetes.

> This repository is based on an upstream Java sample. The application interface is a demonstration; its login form is not backed by an authentication service. AWS resources, Jenkins credentials, Docker Hub access, and host addresses must be configured by each user.

## Architecture

### End-to-end architecture

```mermaid
flowchart TD
    Dev[Developer pushes a change] --> GitHub[GitHub repository]
    GitHub -->|Webhook| Jenkins[Jenkins Pipeline]
    Jenkins -->|Checkout and Maven build/test| WAR[WAR artifact]
    WAR -->|SSH/SCP: app.war and Dockerfile| DockerHost[Remote Docker build host]
    DockerHost -->|Build-number tag and local latest tag| LocalImage[Docker image]
    Jenkins -->|SSH plus Docker Hub credentials on stdin| Ansible[Ansible controller]
    Ansible -->|Play 1: inspect, tag, push| DockerHost
    DockerHost -->|Versioned image| Hub[Docker Hub]
    Ansible -->|Play 2: kubectl update and verify| EKSAdmin[EKS management host]
    EKSAdmin -->|IAM role and kubeconfig| EKS[Amazon EKS cluster]
    EKS --> Deploy[Kubernetes Deployment: 2 replicas]
    Deploy --> Pods[Tomcat application Pods on port 8080]
    Pods --> Service[LoadBalancer Service: port 80 to 8080]
    Service --> Browser[Browser]
```

### What each component does

| Component | Responsibility |
| --- | --- |
| **GitHub** | Stores the application and pipeline source. A push to the configured branch triggers Jenkins through a webhook. |
| **Jenkins** | Checks out the configured SCM, verifies Java/Maven, builds and tests the Maven project, archives the WAR, transfers build inputs, builds the Docker image remotely, and starts Ansible deployment. |
| **Docker build host** | Receives the WAR as `app.war` and the Dockerfile over SSH/SCP. Docker builds `hello-world:<BUILD_NUMBER>` and a local `hello-world:latest` tag. |
| **Ansible controller** | Receives the Docker Hub username and token from Jenkins over SSH standard input, then runs the two deployment plays using its inventory. |
| **Docker host Ansible target** | Verifies the Jenkins-built image, creates temporary Docker auth configuration, logs in with `--password-stdin`, tags the image for Docker Hub, pushes the build-number tag, and removes temporary auth files. |
| **EKS management host** | Uses its attached AWS IAM role and configured kubeconfig to reach the cluster. Ansible updates the Deployment image and verifies the rollout. This is an administration host, not the Kubernetes control plane. |
| **Amazon EKS** | Runs the managed Kubernetes control plane and worker nodes. The Deployment keeps two application replicas available during rolling updates. |
| **LoadBalancer Service** | Exposes HTTP on port 80 and routes to application containers on port 8080. AWS creates the load balancer; its generated hostname is intentionally not stored here. |

### Pipeline stages in detail

1. **Webhook and checkout:** GitHub notifies Jenkins after a push. Jenkins checks out the SCM configured on the job and records the commit.
2. **Build and test:** Jenkins uses the configured Java 21 and Maven 3.10.0 tools and runs `mvn -B -ntp clean package`. The Maven reactor contains the `server` and `webapp` modules; the WAR is generated at `webapp/target/webapp.war`.
3. **Artifact archive:** Jenkins verifies that a WAR exists, archives it, and fingerprints the artifact for traceability.
4. **Transfer to Docker host:** Jenkins uses its SSH credential to copy the WAR and Dockerfile to the remote build host. The WAR is named `app.war`, matching the Dockerfile's `COPY app.war` instruction.
5. **Image build:** The Docker host builds the image from the Tomcat base image in the Dockerfile. It tags the local image with the Jenkins build number and `latest`. The Ansible playbook publishes the versioned tag; it does not push the `latest` tag.
6. **Publish image:** Jenkins invokes Ansible on its controller host. The controller runs Play 1 against the Docker host, verifies the local image, authenticates to Docker Hub using the token from standard input, tags the image as `<DOCKERHUB_NAMESPACE>/hello-world:<BUILD_NUMBER>`, and pushes it.
7. **Deploy to EKS:** Ansible runs Play 2 against the EKS management host. It checks cluster connectivity, updates `hello-world-deployment` to the new image, waits for rollout completion, and verifies two ready replicas.
8. **Serve traffic:** The Kubernetes Service selects pods labeled `app=hello-world`, accepts traffic on port 80, and forwards it to Tomcat on port 8080.

### Kubernetes workload

The Deployment runs two `hello-world-container` replicas in the `default` namespace. Its rolling update strategy sets `maxSurge: 1` and `maxUnavailable: 0`. A TCP readiness probe checks port 8080 after a 10-second initial delay and every 10 seconds. Each pod requests 100m CPU and 256Mi memory, with limits of 500m CPU and 512Mi memory.

The Service is type `LoadBalancer`, uses the same `app=hello-world` selector, and maps TCP port 80 to target port 8080. A cloud load balancer may continue to incur AWS charges until the Service is deleted.

### EKS cluster lifecycle

Cluster provisioning is separate from the Jenkins application pipeline. The sanitized `eks/cluster.example.yaml` documents the `eksctl` configuration: a managed `t3.medium` node group, 20 GiB worker volumes, an initial desired size of zero, and scaling bounds of zero to three. The project scaled the node group to two workers before deploying the application. Scaling workers to zero does not remove the EKS control plane, NAT Gateway, management host, or every networking resource.

### Image tag flow

```text
Jenkins build N
  Docker host: hello-world:N and hello-world:latest (local tags)
  Docker Hub:  <DOCKERHUB_NAMESPACE>/hello-world:N
  EKS:         Deployment updated to <DOCKERHUB_NAMESPACE>/hello-world:N
```

The build-number tag connects a running deployment to a specific Jenkins build. The Docker Hub namespace is a placeholder in this public repository; configure the real repository in Jenkins Credentials/job settings.

## Technology

Java 21 · Maven 3.10.0 · Jenkins · Docker · Ansible · Docker Hub · Kubernetes · Amazon EKS · AWS IAM · eksctl

## Repository structure

```text
.
├── README.md
├── .gitignore
├── Jenkinsfile
├── Dockerfile
├── pom.xml
├── server/                         # Java module
├── webapp/                         # WAR module and demo UI
├── ansible/                        # Sanitized inventory example and deployment playbook
├── kubernetes/                     # EKS Deployment and LoadBalancer Service
├── eks/                            # Sanitized eksctl cluster example
└── docs/                           # Architecture, setup, operations, and security notes
```

See [architecture](docs/architecture.md), [pipeline and automation](docs/pipeline-and-automation.md), [setup guide](docs/setup-guide.md), [EKS and Kubernetes](docs/eks-and-kubernetes.md), and [security notes](docs/security-and-secrets.md).

## Build locally

The Maven project contains `server` and `webapp` modules. The WAR module produces `webapp/target/webapp.war`.

```bash
mvn -B -ntp clean package
```

Jenkins transfers the generated WAR to the Docker host as `app.war`, matching the Dockerfile input.

## Pipeline and deployment

The Jenkinsfile checks out the SCM configured on the Jenkins job. Configure its GitHub webhook and Jenkins tools/credentials in Jenkins itself. Replace the clearly marked host and Docker Hub placeholders before running it. The Ansible example uses a private `inventory.ini` at runtime; only `inventory.example.ini` belongs in the public repository.

The EKS Deployment runs two replicas with a TCP readiness probe on port 8080. The Service exposes port 80 and targets port 8080. A cloud LoadBalancer may incur ongoing charges; the generated endpoint is intentionally not stored here.

## Security

No real credentials, private addresses, personal usernames, or private key paths belong in this repository. Store secrets in Jenkins Credentials and AWS IAM roles. Review [security and secrets](docs/security-and-secrets.md) before adapting the examples.

## Attribution and license

The Java application originated from the [upstream sample project](https://github.com/yankils/hello-world). This repository does not add a license because the upstream reuse terms need to be confirmed first; retain the upstream attribution and check those terms before redistributing inherited code.
