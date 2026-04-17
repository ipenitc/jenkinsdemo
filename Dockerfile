# --- Stage 1: Build (The "Kitchen") ---
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app

# 1. Copy Gradle wrapper and configuration files
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# 2. Fix permissions and download dependencies (cached layer)
RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon

# 3. Copy source code and build the JAR
COPY src src
RUN ./gradlew bootJar -x test --no-daemon

# --- Stage 2: Runtime (The "Serving Plate") ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# 4. Security: Run as a non-root user
RUN useradd -ms /bin/bash springuser
USER springuser

# 5. Copy the built JAR from the builder stage
# Note: Spring Boot 3.3.5 puts the JAR in build/libs/
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8081

# 6. Optimized entrypoint for containers
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]