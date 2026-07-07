# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Copy the Parent POM to the current directory (/app)
COPY pom.xml .

# Copy the Customer POM into its own subfolder
COPY customer/pom.xml customer/

# "Install" the Master POM into the container's internal Maven repo
# -N means "Non-recursive", so it won't try to build the whole project yet
RUN mvn install -N

# Now go into the customer folder and build the module
WORKDIR /app/customer

# Copy the code and build
COPY customer/src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/customer/target/*.jar app.jar

# Install 'curl' so we can check if Eureka is healthy
RUN apk add --no-cache curl

# Expose the port your Spring app runs on
EXPOSE 8080

# Standard production entrypoint to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
