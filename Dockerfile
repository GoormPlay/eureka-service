# 사용할 JDK 버전에 맞춰 이미지를 선택
FROM openjdk:17-jdk-slim

# ARG는 build 시에만 사용 가능한 변수
ARG EUREKA_URL

# ENV는 런타임 환경변수로 전달됨
ENV EUREKA_URL=${EUREKA_URL}

WORKDIR /app

# 빌드된 JAR 파일 복사 (경로 맞춰야 함)
COPY build/libs/app.jar app.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "app.jar"]
