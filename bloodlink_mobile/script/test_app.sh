#!/bin/bash

echo "🧪 Tests BloodLink Mobile"
echo "=========================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de test
test_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

test_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

test_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Test 1: Vérifier Flutter
test_step "Test 1: Vérification de Flutter"
if flutter doctor > /dev/null 2>&1; then
    test_success "Flutter installé"
else
    test_error "Flutter non installé"
    exit 1
fi

# Test 2: Vérifier les dépendances
test_step "Test 2: Vérification des dépendances"
cd ..
flutter pub get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    test_success "Dépendances installées"
else
    test_error "Erreur d'installation des dépendances"
    exit 1
fi

# Test 3: Vérifier la configuration Firebase
test_step "Test 3: Vérification Firebase"
if [ -f "android/app/google-services.json" ]; then
    test_success "google-services.json trouvé"
else
    test_error "google-services.json manquant"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    test_success "GoogleService-Info.plist trouvé"
else
    test_error "GoogleService-Info.plist manquant"
fi

# Test 4: Vérifier la configuration backend
test_step "Test 4: Vérification backend URL"
BACKEND_URL=$(grep "baseUrl" lib/config/app_config.dart | cut -d"'" -f2)
echo "   Backend URL: $BACKEND_URL"

# Test 5: Build de test
test_step "Test 5: Build de test"
flutter build apk --debug > /dev/null 2>&1
if [ $? -eq 0 ]; then
    test_success "Build Android réussi"
else
    test_error "Erreur de build Android"
fi

echo ""
echo "=========================="
echo "✅ Tests terminés"