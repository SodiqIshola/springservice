# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Copy the Parent POM to the current directory (/app)
COPY pom.xml .

# Copy the Fraud POM into its own subfolder
COPY fraud/pom.xml fraud/

# "Install" the Master POM into the container's internal Maven repo
# -N means "Non-recursive", so it won't try to build the whole project yet
RUN mvn install -N

# Now go into the fraud folder and pull dependencies
WORKDIR /app/fraud
RUN mvn dependency:go-offline

# Copy the code and build
COPY fraud/src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/fraud/target/*.jar app.jar

# Install 'curl' so we can check if Eureka is healthy
RUN apk add --no-cache curl

# Expose the port your Spring app runs on
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
