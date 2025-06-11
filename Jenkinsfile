pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('docker-hub-username')
        DOCKER_PASSWORD = credentials('docker-hub-password')
        GITHUB_TOKEN    = credentials('github-token')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    // Get branch name with fallback for multibranch vs regular pipeline
                    def branchName = env.BRANCH_NAME ?: env.GIT_BRANCH?.replaceAll('origin/', '')
                    echo "Building for branch: ${branchName}"
                    
                    // Check Docker access
                    sh 'docker --version'
                    sh 'docker info'
                    
                    // Fix permission issue by making scripts executable
                    sh 'chmod +x build.sh'
                    sh './build.sh'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Get branch name with fallback
                    def branchName = env.BRANCH_NAME ?: env.GIT_BRANCH?.replaceAll('origin/', '')
                    echo "Pushing Docker images for branch: ${branchName}"

                    // Login to Docker Hub with better error handling
                    sh """
                        echo "Attempting to login to Docker Hub..."
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                        echo "Docker login successful!"
                    """

                    // Tag and push images based on branch
                    if (branchName == 'dev') {
                        sh """
                            # Tag the built image for dev repository
                            docker tag reacttestapp:latest \$DOCKER_USERNAME/dev:dev
                            docker tag reacttestapp:latest \$DOCKER_USERNAME/dev:latest
                            
                            # Push images to dev repository
                            docker push \$DOCKER_USERNAME/dev:dev
                            docker push \$DOCKER_USERNAME/dev:latest
                        """
                    } else if (branchName == 'main') {
                        sh """
                            # Tag the built image for prod repository
                            docker tag reacttestapp:latest \$DOCKER_USERNAME/prod:prod
                            docker tag reacttestapp:latest \$DOCKER_USERNAME/prod:latest
                            
                            # Push images to prod repository
                            docker push \$DOCKER_USERNAME/prod:prod
                            docker push \$DOCKER_USERNAME/prod:latest
                        """
                    } else {
                        echo "No Docker push configured for branch: ${branchName}"
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                script {
                    def branchName = env.BRANCH_NAME ?: env.GIT_BRANCH?.replaceAll('origin/', '')
                    echo "Deploying for branch: ${branchName}"
                    
                    // Fix permission issue for deploy script
                    sh 'chmod +x deploy.sh'
                    sh './deploy.sh'
                }
            }
        }
    }

    post {
        always {
            script {
                // Always logout from Docker Hub
                sh 'docker logout || true'
            }
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        cleanup {
            // Clean up workspace if needed
            cleanWs()
        }
    }
}
