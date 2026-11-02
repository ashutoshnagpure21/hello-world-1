pipeline {
    agent any

    tools {
        jdk 'java-21'
        maven 'maven-3.10.0'
    }

    options {
        timestamps()
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    environment {
        // Replace placeholders in Jenkins/job configuration; do not commit real host details.
        DOCKER_HOST_ADDRESS = 'REPLACE_WITH_DOCKER_HOST_ADDRESS'
        DOCKER_USER = 'REPLACE_WITH_DOCKER_USER'
        DOCKER_APP_DIR = '/opt/hello-world'

        ANSIBLE_HOST_ADDRESS = 'REPLACE_WITH_ANSIBLE_CONTROLLER_ADDRESS'
        ANSIBLE_USER = 'REPLACE_WITH_ANSIBLE_USER'
        ANSIBLE_PROJECT_DIR = '/opt/ansible/hello-world'

        IMAGE_NAME = 'hello-world'
        DOCKERHUB_REPOSITORY = 'your-dockerhub-namespace/hello-world'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Configure the repository and webhook on the Jenkins job.
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    set -e
                    java -version
                    mvn -version
                    mvn -B -ntp help:evaluate -Dexpression=project.artifactId -q -DforceStdout
                '''
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn -B -ntp clean package'
            }
        }

        stage('Verify and Archive WAR') {
            steps {
                sh '''
                    set -e
                    WAR_FILE=$(find . -type f -path '*/target/*.war' -print -quit)
                    if [ -z "$WAR_FILE" ]; then
                        echo "ERROR: No WAR file generated"
                        exit 1
                    fi
                    ls -lh "$WAR_FILE"
                '''
                archiveArtifacts(artifacts: '**/target/*.war', fingerprint: true)
            }
        }

        stage('Transfer Files to Docker Host') {
            steps {
                script {
                    def warFile = sh(
                        script: "find . -type f -path '*/target/*.war' -print -quit",
                        returnStdout: true
                    ).trim()
                    if (!warFile) {
                        error('WAR file not found')
                    }
                    withEnv(['WAR_FILE=' + warFile]) {
                        sshagent(credentials: ['docker-host-ssh-key']) {
                            sh '''
                                set -e
                                ssh -o BatchMode=yes $DOCKER_USER@$DOCKER_HOST_ADDRESS "mkdir -p $DOCKER_APP_DIR"
                                scp -o BatchMode=yes "$WAR_FILE" $DOCKER_USER@$DOCKER_HOST_ADDRESS:$DOCKER_APP_DIR/app.war
                                scp -o BatchMode=yes Dockerfile $DOCKER_USER@$DOCKER_HOST_ADDRESS:$DOCKER_APP_DIR/Dockerfile
                            '''
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sshagent(credentials: ['docker-host-ssh-key']) {
                    sh '''
                        set -e
                        ssh -o BatchMode=yes $DOCKER_USER@$DOCKER_HOST_ADDRESS \
                            "docker build -t $IMAGE_NAME:$BUILD_NUMBER -t $IMAGE_NAME:latest $DOCKER_APP_DIR"
                        ssh -o BatchMode=yes $DOCKER_USER@$DOCKER_HOST_ADDRESS \
                            "docker image inspect $IMAGE_NAME:$BUILD_NUMBER"
                    '''
                }
            }
        }

        stage('Deploy via Ansible to EKS') {
            steps {
                sshagent(credentials: ['ansible-host-ssh-key']) {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKERHUB_USER',
                            passwordVariable: 'DOCKERHUB_TOKEN'
                        )
                    ]) {
                        sh '''
                            set +x
                            set -e
                            printf '%s\\n%s\\n' "$DOCKERHUB_USER" "$DOCKERHUB_TOKEN" | \\
                            ssh -T -o BatchMode=yes $ANSIBLE_USER@$ANSIBLE_HOST_ADDRESS \\
                                "IFS= read -r DOCKERHUB_USER && \\
                                 IFS= read -r DOCKERHUB_TOKEN && \\
                                 export DOCKERHUB_USER DOCKERHUB_TOKEN && \\
                                 cd $ANSIBLE_PROJECT_DIR && \\
                                 ansible-playbook -i inventory.ini deploy.yml \\
                                   -e dockerhub_repository=$DOCKERHUB_REPOSITORY \\
                                   -e build_number=$BUILD_NUMBER"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Image published and application rollout completed.'
            echo 'Deployed image: ' + env.DOCKERHUB_REPOSITORY + ':' + env.BUILD_NUMBER
        }
        failure {
            echo 'FAILED: Review the Jenkins console output for the failed stage.'
        }
        always {
            junit(testResults: '**/target/surefire-reports/TEST-*.xml', allowEmptyResults: true)
        }
    }
}
