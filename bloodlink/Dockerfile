# Étape 1 : Build (Compilation avec Maven)
FROM maven:3.9.6-eclipse-temurin-21 AS build
#WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Étape 2 : Runtime (Image légère pour l'exécution)
FROM eclipse-temurin:21-jre-alpine
#WORKDIR /app
# Copie le jar généré depuis l'étape de build
COPY --from=build /target/*.jar app.jar
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "app.jar"]
