pipeline {
    agent any

    parameters {
        string(name: 'EUREKA_URL', defaultValue: 'http://gpadmin:1234@10.0.11.103:8761/eureka', description: 'Eureka 서버 URL')
    }

    environment {
        DOCKER_IMAGE_NAME = 'roin09/eureka-service'
        DOCKER_IMAGE_TAG = 'latest'
        DEPLOY_HOST = '10.0.11.103' // 배포 서버 Private IP
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            steps {
                sh './gradlew clean build -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg EUREKA_URL=${params.EUREKA_URL} -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EC2 via SSH') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${DEPLOY_HOST} << 'ENDSSH'
                      docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                      docker stop eureka-service || true
                      docker rm eureka-service || true
                      docker run -d --name eureka-service -p 8761:8761 -e EUREKA_URL='${params.EUREKA_URL}' ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    ENDSSH
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
