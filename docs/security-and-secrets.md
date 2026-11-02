# Security and secret handling

This project is intended for a public portfolio repository. Keep credentials and identifying infrastructure values out of tracked files, screenshots, and command output.

## Credential handling shown by the project

- Jenkins stores SSH keys and Docker Hub credentials in its Credentials store; pipeline code refers to credential IDs.
- The Docker Hub token is sent from Jenkins to the Ansible controller through SSH standard input, rather than a command-line argument.
- The Ansible Docker login task uses `--password-stdin` and `no_log: true`.
- Docker authentication uses a temporary config directory that the playbook removes in an `always` block.
- The EKS management host authenticates to AWS through an attached EC2 IAM role; the project notes describe an IAM role with broad lab permissions.

These controls reduce accidental exposure in logs and repository files. They do not replace rotating a credential if it has ever been exposed.

## Replace before public commit

Use placeholders or example values for:

- Docker Hub account namespace
- Private IP addresses, hostnames, and public load balancer endpoints
- Linux usernames, SSH key file paths, and Jenkins agent/controller locations
- AWS account IDs, IAM role ARNs, cluster names, node group names, and private network details
- Any kubeconfig, private key, certificate, password, token, or webhook secret

Credential IDs are identifiers, not the credentials themselves, but generic example IDs are clearer in a portfolio.

## Security review findings

- The pasted Jenkinsfile and playbook did not include literal secret values or private-key contents.
- The shared inventory and EKS notes included private addresses, usernames, key paths, account/cluster identifiers, and environment details; these should be generalized before publication.
- The EKS notes describe an administrative lab role and a public API endpoint. Use least privilege and restrict the API endpoint for production environments.
- The Kubernetes Service provisions public access through an AWS LoadBalancer. Avoid committing its generated hostname; confirm the AWS resource is removed when no longer needed.
- If credentials were ever committed to Git history, revoke or rotate them; deleting a current file alone does not remove historical exposure.

## Safe example configuration

Publish files such as `inventory.example.ini` and `cluster.example.yaml` with placeholders, while keeping the real inventory and local credential files ignored by Git. Use a `.gitignore` to exclude kubeconfig files, private keys, Ansible retry files, local environment files, and build outputs.

