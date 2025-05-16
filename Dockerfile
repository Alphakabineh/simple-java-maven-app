# --------- Build Stage ---------
    FROM maven:3.9.4-eclipse-temurin-17 AS builder
 
    # Set work directory 
    WORKDIR /app
   
    # Copy pom.xml and download dependencies
    COPY pom.xml .
    RUN mvn dependency:go-offline
   
    # Copy the rest of the project files
    COPY . .
   
    # Package the app
    RUN mvn clean package -DskipTests
   
    # --------- Runtime Stage ---------
    FROM eclipse-temurin:17-jre
   
    # Set work directory
    WORKDIR /app
   
    # Copy only the JAR from the builder stage
    COPY --from=builder /app/target/*.jar app.jar
   
    # Expose the default app port (adjust if needed)
    EXPOSE 8080
   
    # Run the app
    ENTRYPOINT ["java", "-jar", "app.jar"]
   
 