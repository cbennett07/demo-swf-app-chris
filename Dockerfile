FROM eclipse-temurin:17-jdk AS build
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y npm
RUN ./gradlew build

# Stage 2: Create the final image
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/demo-swf-app-chris-0.0.1-SNAPSHOT.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
