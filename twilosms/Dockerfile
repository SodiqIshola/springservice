# ============================================================================
# Multi-Stage Dockerfile: Twilio SMS Service
# Stage 1: Build (Maven + JDK 21)
# Stage 2: Runtime (JRE 21 Alpine) - Optimized for production
# ============================================================================

# Stage 1: Compile and Package
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Copy Master/Parent POM to resolve project-wide dependencies and versions
COPY pom.xml .

# Replicate the module structure for the child project
COPY twilosms/pom.xml twilosms/

# Install Parent POM into local container repo (-N: Non-recursive)
RUN mvn install -N

# Cache dependencies for the specific module to speed up future builds
WORKDIR /app/twilosms
RUN mvn dependency:go-offline

# Copy source code and build the executable "Fat JAR"
COPY twilosms/src ./src
RUN mvn clean package -DskipTests


# Stage 2: Lean Runtime Environment
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Import only the final JAR from the build stage to keep the image small
COPY --from=build /app/twilosms/target/*.jar app.jar

# Install 'curl' for Docker Healthchecks (Actuator monitoring)
RUN apk add --no-cache curl

# Document the application port (matches application.yml configuration)
EXPOSE 8444

# Standard production entrypoint to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
