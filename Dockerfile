# Use the official OpenJDK 22 image as a base
FROM openjdk:22-jdk-slim as build

# Set the working directory in the Docker image
WORKDIR /app

# Copy the Maven pom.xml file and source code into the Docker image
COPY . .

# Install Maven in the Docker image and build the application
RUN apt-get update && \
    apt-get install -y maven && \
    mvn clean package -DskipTests

# Start a new build stage
FROM openjdk:22-jdk-slim

# Set the working directory to /app
WORKDIR /app

# Expose the port the app runs on
EXPOSE 8761

# Copy the built jar file from the previous stage into this new stage
COPY --from=build /app/target/first-service-*.jar /app/first-service.jar

# Command to run the application
ENTRYPOINT ["java", "-jar", "/app/first-service.jar"]
