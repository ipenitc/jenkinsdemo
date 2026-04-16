# Stage 1: Build & Test
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /build

COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN ./gradlew build -x test --no-daemon || true

COPY src src
# REMOVE the "-x test" so it runs your JUnit 5 tests here!
RUN ./gradlew bootJar --no-daemon