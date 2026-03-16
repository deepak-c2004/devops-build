pipeline {
    agent any

    environment {
        DEV_IMAGE  = "deepakc742004/dev"
        PROD_IMAGE = "deepakc742004/prod"
        TAG        = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}",
                    url: 'https://github.com/deepak-c2004/devops-build.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == "dev") {
                        sh "docker build -t ${DEV_IMAGE}:${TAG} -t ${DEV_IMAGE}:latest ."
                    } else if (env.BRANCH_NAME == "master") {
                        sh "docker build -t ${PROD_IMAGE}:${TAG} -t ${PROD_IMAGE}:latest ."
                    }
                }
            }
        }

        stage('DockerHub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == "dev") {
                        sh "docker push ${DEV_IMAGE}:${TAG}"
                        sh "docker push ${DEV_IMAGE}:latest"
                    } else if (env.BRANCH_NAME == "master") {
                        sh "docker push ${PROD_IMAGE}:${TAG}"
                        sh "docker push ${PROD_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-key',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    script {
                        if (env.BRANCH_NAME == "dev") {
                            sh """
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ubuntu@YOUR_EC2_PUBLIC_IP \
                            'docker pull ${DEV_IMAGE}:latest &&
                             docker stop devops-build-app || true &&
                             docker rm devops-build-app || true &&
                             docker run -d --name devops-build-app -p 80:80 --restart always ${DEV_IMAGE}:latest'
                            """
                        } else if (env.BRANCH_NAME == "master") {
                            sh """
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ubuntu@YOUR_EC2_PUBLIC_IP \
                            'docker pull ${PROD_IMAGE}:latest &&
                             docker stop devops-build-app || true &&
                             docker rm devops-build-app || true &&
                             docker run -d --name devops-build-app -p 80:80 --restart always ${PROD_IMAGE}:latest'
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
