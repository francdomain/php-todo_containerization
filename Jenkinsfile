pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "docker.io/francdocmain"
        DOCKER_IMAGE = "php-todo-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME
                    def tagName = branchName == 'master' ? 'latest' : "${branchName}-${env.BUILD_NUMBER}"

                    // Build Docker image
                    sh """
                    docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${tagName} .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME
                    def tagName = branchName == 'master' ? 'latest' : "${branchName}-${env.BUILD_NUMBER}"

                    // Use Jenkins credentials to login to Docker and push the image
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                        docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} ${DOCKER_REGISTRY}
                        docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${tagName}
                        """
                    }
                }
            }
        }

    }

    post {
        always {
            // Clean up Docker images to save space
            sh "docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${tagName}"
        }
    }
}