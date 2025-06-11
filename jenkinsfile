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
                    def branchName = env.BRANCH_NAME
                    echo "Building for branch: ${branchName}"
                    
                    sh './build.sh'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME

                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                    """

                    if (branchName == 'dev') {
                        sh "docker push \$DOCKER_USERNAME/dev:dev"
                        sh "docker push \$DOCKER_USERNAME/dev:latest"
                    } else if (branchName == 'main') {
                        sh "docker push \$DOCKER_USERNAME/prod:prod"
                        sh "docker push \$DOCKER_USERNAME/prod:latest"
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
                    sh './deploy.sh'
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
