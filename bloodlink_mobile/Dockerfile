# Etape 1 : Construction de l'application Flutter
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY pubspec.yaml pubspec.lock ./

# Récupérer les dépendances
RUN flutter pub get

# Copier tout le reste du code source
COPY . .

# Construire l'application pour le web
# --release optimise le code
# --web-renderer html ou canvaskit (auto par défaut, html est souvent plus léger au chargement)
RUN flutter build web --release

# Etape 2 : Serveur Web Nginx pour servir l'application
FROM nginx:alpine

# Copier le build Flutter vers le dossier par défaut de Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copier la configuration Nginx personnalisée (optionnel mais recommandé pour le routing)
# Nous allons créer ce fichier juste après
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]