#!/bin/bash

# Script pour exécuter les tests unitaires et générer des rapports JUnit XML
# S'adapte automatiquement aux projets (Gradle ou NPM)

# Définition des chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/test-results"
TESTS_FAILED=0


echo "========================================"
echo "Préparation de l'environnement de test"
echo "========================================"

# Création ou nettoyage du dossier des résultats
rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

# Parcourir les sous-dossiers
for dir in "$SCRIPT_DIR"/*/; do
    # Ignorer le dossier test-results lui-même
    if [ "$dir" = "$RESULTS_DIR/" ]; then
        continue
    fi

    dir=${dir%/}
    echo "$dir";
    dir_name=$(basename "$dir")

    # Ignorer les dossiers cachés
    if [[ "$dir_name" == .* ]]; then
        continue
    fi

    echo ""
    echo "========================================"
    echo "Analyse du dossier : $dir_name"
    
    # Détection Gradle
    if [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ] || [ -f "$dir/gradlew" ]; then
        echo "Type de projet détecté : Gradle (Backend Java)"
        (
            cd "$dir"
            echo "-> Ajout des droits d'exécution au script Gradle..."
            chmod +x ./gradlew
            echo "-> Lancement des tests avec Gradle..."
            if ! ./gradlew clean test; then
                echo "   /!\ Les tests Gradle ont échoué."
                TESTS_FAILED=1
            fi
            echo "-> Récupération des rapports JUnit XML..."
            
            # Gradle place les rapports dans build/test-results/test/
            if [ -d "build/test-results/test" ]; then
                find build/test-results/test -name "*.xml" -exec cp {} "$RESULTS_DIR/" \;
                echo "   Rapports copiés avec succès dans $RESULTS_DIR."
            else
                echo "   Aucun rapport XML trouvé (les tests ont peut-être échoué avant génération)."
            fi
        )
    # Détection NPM
    elif [ -f "$dir/package.json" ]; then
        echo "Type de projet détecté : NPM (Frontend)"
        (
            cd "$dir"
            echo "-> Installation des dépendances (NPM)..."
            npm ci || npm install
            
            echo "-> Lancement des tests avec NPM..."
            if ! npm run test; then
                echo "   /!\ Les tests NPM ont échoué."
                TESTS_FAILED=1
            fi
            
            echo "-> Récupération des rapports JUnit XML..."
            # Karma/Jest est généralement configuré pour placer les rapports dans reports/ ou coverage/
            # D'après la configuration, le dossier cible est reports/
            if [ -d "reports" ]; then
                for xml_file in reports/*.xml; do
                    if [ -f "$xml_file" ]; then
                        base_xml=$(basename "$xml_file")
                        # Ajout du nom du projet en préfixe pour éviter d'écraser des fichiers de même nom
                        cp "$xml_file" "$RESULTS_DIR/${dir_name}-${base_xml}"
                    fi
                done
                echo "   Rapports copiés avec succès dans $RESULTS_DIR."
            else
                echo "   Aucun rapport XML trouvé."
            fi
        )
    else
        echo "Aucun type de projet reconnu (ni Gradle ni NPM). Ignoré."
    fi
done

echo ""
echo "========================================"
echo "Les rapports JUnit XML consolidés sont disponibles dans : $RESULTS_DIR"

if [ $TESTS_FAILED -ne 0 ]; then
    echo "Attention : Certains tests ont échoué !"
    echo "========================================"
    exit 1
else
    echo "Tous les tests ont été exécutés avec succès !"
    echo "========================================"
    exit 0
fi