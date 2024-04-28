FROM openjdk:17-jdk-slim AS build
WORKDIR /app
COPY . .

RUN apt-get update
RUN apt-get install -y npm
RUN ./gradlew build

# Stage 2: Create the final image
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/build/libs/demo-swf-app-chris-0.0.1-SNAPSHOT.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
