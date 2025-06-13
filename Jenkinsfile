pipeline {
    agent any

    parameters {
        string(name: 'EUREKA_URL', defaultValue: 'http://10.0.11.103:8761/eureka', description: 'Eureka 서버 URL')
    }

    environment {
        DOCKER_IMAGE_NAME = 'roin09/eureka-service'
        DOCKER_IMAGE_TAG = 'latest'
        DEPLOY_HOST = '10.0.11.103'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            steps {
                sh 'chmod +x ./gradlew' // Permission 문제 방지
                sh './gradlew clean build -x test'
                sh 'cp build/libs/eureka-service-0.0.1-SNAPSHOT.jar build/libs/app.jar'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg EUREKA_URL=${params.EUREKA_URL} -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EC2 via SSH') {
            steps {
                sshagent (credentials: ['ec2-ssh-key-id']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} "docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} "docker stop eureka-service || true"
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} "docker rm eureka-service || true"
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} "docker container prune -f || true"
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} "docker run -d --name eureka-service -p 8761:8761 -e EUREKA_URL='${params.EUREKA_URL}' ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
