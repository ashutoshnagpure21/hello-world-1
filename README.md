# Java CI/CD Pipeline on Amazon EKS

A learning project that automates delivery of a Java web application to Amazon EKS. Jenkins builds and tests the Maven application, packages a WAR, builds a Docker image on a remote host, and invokes Ansible to publish a versioned image and roll it out to Kubernetes.

> This repository is based on an upstream Java sample. The application interface is a demonstration; its login form is not backed by an authentication service. AWS resources, Jenkins credentials, Docker Hub access, and host addresses must be configured by each user.

## Delivery flow

```text
GitHub push / webhook
  → Jenkins checkout and Maven build/test
  → archive WAR
  → SSH transfer WAR + Dockerfile to Docker build host
  → build hello-world:<BUILD_NUMBER> and hello-world:latest
  → Ansible tags and pushes the versioned image to Docker Hub
  → Ansible updates the EKS Deployment and verifies rollout
  → two ready replicas behind a LoadBalancer Service (port 80 → 8080)
```

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
