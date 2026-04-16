# --- Stage 1: Build (The "Kitchen") ---
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app

# Copy only the wrapper files first to cache dependencies
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon

# Now copy source and build
COPY src src
RUN ./gradlew bootJar --no-daemon

# --- Stage 2: Runtime (The "Serving Plate") ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Security: Create a non-privileged user
RUN useradd -ms /bin/bash springuser
USER springuser

# Copy only the JAR from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Optimization: JVM flags for containers
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]