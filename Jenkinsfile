pipeline {
    agent any

    parameters {
        string(name: 'EUREKA_URL', defaultValue: 'http://gpadmin:1234@10.0.11.103:8761/eureka', description: 'Eureka 서버 URL')
    }

    environment {
        DOCKER_IMAGE_NAME = 'eureka-service'
        DOCKER_IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            steps {
                // Gradle 기준
                sh './gradlew clean build -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build --build-arg EUREKA_URL=${params.EUREKA_URL} -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Run Docker Container (Optional)') {
            steps {
                script {
                    sh "docker stop ${DOCKER_IMAGE_NAME} || true"
                    sh "docker rm ${DOCKER_IMAGE_NAME} || true"
                    sh "docker run -d --name ${DOCKER_IMAGE_NAME} -p 8761:8761 -e EUREKA_URL='${params.EUREKA_URL}' ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
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
