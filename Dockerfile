# Use a build stage to compile and package the Java application
FROM openjdk:22-jdk-slim as build
WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copy the Maven pom.xml file and source code into the Docker image
COPY . .

# Build the application without running tests
RUN mvn clean package -DskipTests

# Start a new build stage for running the application
FROM openjdk:22-jdk-slim
WORKDIR /app


# Install network utilities
RUN apt-get update && apt-get install -y curl iputils-ping && rm -rf /var/lib/apt/lists/*

# Copy the built jar file from the previous stage
COPY --from=build /app/target/first-service-*.jar /app/first-service.jar

# Command to run the application
ENTRYPOINT ["java", "-jar", "/app/first-service.jar"]
