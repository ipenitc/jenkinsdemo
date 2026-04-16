# --- Stage 1: Build Stage ---
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /build

# Copy gradle files first to leverage Docker layer caching
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Download dependencies (this layer is cached unless build.gradle changes)
RUN ./gradlew build -x test --no-daemon > /dev/null 2>&1 || true

# Copy source code and build the application
COPY src src
RUN ./gradlew bootJar -x test --no-daemon

# --- Stage 2: Runtime Stage ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Create a non-root user for security
RUN useradd -ms /bin/bash springuser
USER springuser

# Copy the JAR from the builder stage
COPY --from=builder /build/build/libs/*.jar app.jar

# Standard Spring Boot port
EXPOSE 8080

# Use optimized JVM flags for containers
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]