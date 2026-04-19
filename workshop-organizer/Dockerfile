# Étape 1 : Construction de l'application (Build)
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app

# Copie des fichiers nécessaires pour Gradle
COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./

# Convertir les fins de ligne Windows (CRLF) en Linux (LF) pour éviter l'erreur "not found" et rendre exécutable
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

# Téléchargement des dépendances (permet de mettre en cache cette étape)
RUN ./gradlew dependencies --no-daemon

# Copie du code source du projet
COPY src/ src/

# Construction de l'exécutable (bootWar) en excluant les tests
RUN ./gradlew bootWar -x test --no-daemon

# Étape 2 : Création de l'image finale d'exécution (Run)
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Récupération de l'archive .war construite à l'étape précédente
COPY --from=builder /app/build/libs/*.war app.war

# Exposition du port par défaut de Spring Boot
EXPOSE 8080

# Commande de démarrage de l'application
ENTRYPOINT ["java", "-jar", "app.war"]