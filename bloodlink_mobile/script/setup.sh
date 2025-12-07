#!/bin/bash

echo "🚀 Configuration de BloodLink..."

# 1. Nettoyer
echo "📦 Nettoyage..."
flutter clean

# 2. Installer les dépendances
echo "📥 Installation des dépendances..."
flutter pub get

# 3. Générer les fichiers
echo "🔧 Génération des fichiers..."
# Si vous utilisez build_runner plus tard
# flutter pub run build_runner build --delete-conflicting-outputs

# 4. Vérifier la configuration
echo "✅ Vérification..."
flutter doctor

echo "✨ Configuration terminée !"
echo ""
echo "Pour lancer l'app:"
echo "  - Android: flutter run"
echo "  - iOS: flutter run -d ios"
echo ""
echo "N'oubliez pas de:"
echo "  1. Ajouter google-services.json dans android/app/"
echo "  2. Ajouter GoogleService-Info.plist dans ios/Runner/"
echo "  3. Configurer votre URL backend dans lib/config/app_config.dart"