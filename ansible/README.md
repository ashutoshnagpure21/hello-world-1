# Ansible deployment

The playbook has two plays. The first runs on the Docker build host to verify, tag, and push the Jenkins-built image. The second runs on the EKS management host to update the Kubernetes Deployment and wait for two ready replicas.

## Configure

1. Copy `inventory.example.ini` to `inventory.ini` on the Ansible controller.
2. Replace host, user, and private-key-path placeholders locally. The real inventory is ignored by Git.
3. Ensure the Docker host has access to the image built by Jenkins and can reach Docker Hub.
4. Ensure the EKS management host has AWS CLI, kubectl, a working IAM role, and a configured kubeconfig.
5. Store Docker Hub credentials in Jenkins Credentials. The pipeline transfers them over SSH standard input; do not put them in inventory or playbook files.

Jenkins runs `ansible-playbook -i inventory.ini deploy.yml` from this project directory and passes the build number and Docker Hub repository as extra variables. The playbook defaults to tag `4` only for manual runs that omit a build number.
