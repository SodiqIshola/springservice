# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Copy the Parent POM to the current directory (/app)
COPY pom.xml .

# Copy the eureka-server POM into its own subfolder
COPY eureka-server/pom.xml eureka-server/

# "Install" the Master POM into the container's internal Maven repo
# -N means "Non-recursive", so it won't try to build the whole project yet
RUN mvn install -N

# Now go into the eureka-server folder and pull dependencies
WORKDIR /app/eureka-server
RUN mvn dependency:go-offline

# Copy the source code and build the package
COPY eureka-server/src ./src
RUN mvn clean package -DskipTests


# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# INSTALL CURL HERE (For Alpine base images)
RUN apk add --no-cache curl

# Copy the JAR from the build stage
COPY --from=build /app/eureka-server/target/*.jar app.jar

# Expose the port your Spring app runs on
EXPOSE 8761

# Standard production entrypoint to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
