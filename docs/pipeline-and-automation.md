# Jenkins and Ansible pipeline

## Jenkins pipeline stages

1. Check out the SCM configured on the Jenkins job (the original job used `master`) and log the checked-out commit.
2. Verify the configured Java and Maven tools and print the Maven project artifact ID.
3. Run `mvn -B -ntp clean package` to compile, test, and package the project.
4. Find and verify a generated WAR file.
5. Archive WAR files in Jenkins and fingerprint the artifacts.
6. Verify the Dockerfile exists.
7. Transfer the WAR as `app.war` and the Dockerfile to the remote Docker host using the Jenkins SSH agent credential.
8. Build `hello-world:<BUILD_NUMBER>` and `hello-world:latest` on the remote Docker host.
9. Use the second Jenkins SSH credential to invoke Ansible. Bind Docker Hub credentials from Jenkins Credentials, send the token over SSH standard input, and pass the Jenkins build number to `deploy.yml`.
10. Publish Maven JUnit reports and report pipeline success or failure.

The Jenkins tool names configured in the shared pipeline are Java 21 and Maven 3.10.0. SSH credential IDs and host details should be supplied by the Jenkins environment and examples should use generic IDs.

## WAR and Docker handoff

The `webapp` Maven module sets its final artifact name to `webapp`, producing `webapp/target/webapp.war`. Jenkins selects the first WAR found under a module `target` directory, then copies it to the Docker host under the filename `app.war`. The Dockerfile copies `app.war` into Tomcat as the root application.

## Ansible Play 1: publish image

Runs against inventory group `docker_host`:

1. Assert that the Docker Hub token, username, and repository are available to Ansible, with task output hidden.
2. Verify the Jenkins-built local image `hello-world:<BUILD_NUMBER>` exists.
3. Create a temporary Docker config directory.
4. Log in to Docker Hub using `--password-stdin` and hide login output.
5. Tag the image as `<DOCKERHUB_NAMESPACE>/hello-world:<BUILD_NUMBER>`.
6. Push the versioned image and remove the temporary Docker config directory in an `always` block.

The playbook defaults `build_number` to `4` if it is not supplied. Jenkins passes its build number, so documentation should explain that the fallback is for manual invocation only.

## Ansible Play 2: deploy to EKS

Runs against inventory group `eks_host`:

1. Check `kubectl cluster-info` connectivity.
2. Verify the existing `hello-world-deployment` in the `default` namespace.
3. Set the `hello-world-container` image to the new Docker Hub build tag.
4. Wait up to 300 seconds for rollout completion.
5. Wait for exactly two ready replicas, then display the Deployment and matching pods.

The EKS management host authenticates to AWS through its attached IAM role and uses its configured kubeconfig. The Ansible controller connects over SSH using a dedicated key.

## Configuration and execution

The shared `ansible.cfg` uses `./inventory.ini`, enables host key checking, disables retry files, sets a 30-second timeout, and enables SSH connection reuse and pipelining. Inventory entries override the default `remote_user` for each host.

Jenkins invokes Ansible from the configured project directory with `-i inventory.ini`, `deploy.yml`, and `-e build_number=<BUILD_NUMBER>`. Keep host addresses, Linux usernames, private-key paths, and account identifiers in private infrastructure configuration; publish only `inventory.example.ini` with placeholders.

## Portfolio improvement notes

- The sanitized Jenkinsfile passes `DOCKERHUB_REPOSITORY` to Ansible as an extra variable, avoiding a hardcoded account namespace.
- `latest` is built but only the immutable build-number tag is pushed/deployed by the shown Ansible playbook. Document this distinction.
- The Ansible playbook's two-replica readiness check is fixed at `2`; if replica count becomes configurable, share one variable between the manifest and verification.
- Keep deployment failures visible: the playbook commands return nonzero on failure and Jenkins fails when the remote Ansible command exits unsuccessfully.

