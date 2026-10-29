#!/bin/bash
# Build app bundle (.aab) using Flutter product flavors.
#
# Usage:
#   ./b.sh                          # Build PROD app bundle (default)
#   ./b.sh prod                     # Build PROD app bundle
#   ./b.sh dev                      # Build DEV app bundle
#   ./b.sh prod custom-name         # Build PROD app bundle with custom name
#   ./b.sh dev custom-name          # Build DEV app bundle with custom name

set -e

EXPECTED_PROD_BASE_URL="https://api.voiceclubapp.in/api/v1"
PROD_ENV_FILE=".env.prod"

# Parse environment argument (default: prod)
ENVIRONMENT="${1:-prod}"
ENVIRONMENT_LOWER=$(echo "$ENVIRONMENT" | tr '[:upper:]' '[:lower:]')

if [ "$ENVIRONMENT_LOWER" != "dev" ] && [ "$ENVIRONMENT_LOWER" != "prod" ]; then
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: ./b.sh [dev|prod] [custom_name]"
    exit 1
fi

# Strict safety check for production builds.
if [ "$ENVIRONMENT_LOWER" = "prod" ]; then
    if [ ! -f "$PROD_ENV_FILE" ]; then
        echo "❌ Production env file not found: $PROD_ENV_FILE"
        exit 1
    fi

    PROD_BASE_URL=$(sed -n 's/^[[:space:]]*BASE_URL[[:space:]]*=[[:space:]]*//p' "$PROD_ENV_FILE" | sed -n '1p' | tr -d '\r')

    if [ -z "$PROD_BASE_URL" ]; then
        echo "❌ BASE_URL not found in $PROD_ENV_FILE"
        exit 1
    fi

    if [ "$PROD_BASE_URL" != "$EXPECTED_PROD_BASE_URL" ]; then
        echo "❌ Production safety check failed."
        echo "   Expected BASE_URL: $EXPECTED_PROD_BASE_URL"
        echo "   Found BASE_URL:    $PROD_BASE_URL"
        echo "   Build aborted."
        exit 1
    fi

    echo "✅ Production BASE_URL safety check passed."
fi

# Set target file based on environment.
if [ "$ENVIRONMENT_LOWER" = "dev" ]; then
    TARGET_FILE="lib/main_dev.dart"
    ENVIRONMENT_LABEL="DEV"
else
    TARGET_FILE="lib/main_prod.dart"
    ENVIRONMENT_LABEL="PROD"
fi

# Read APP_VERSION from pubspec.yaml.
PUBSPEC_FILE="pubspec.yaml"
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Warning: pubspec.yaml not found, using 'unknown' for version"
    APP_VERSION="unknown"
else
    APP_VERSION=$(sed -n 's/^version:[[:space:]]*//p' "$PUBSPEC_FILE" | sed -n '1p' | cut -d'+' -f1 | tr -d ' ')
    if [ -z "$APP_VERSION" ]; then
        echo "Warning: Could not read version from pubspec.yaml, using 'unknown'"
        APP_VERSION="unknown"
    fi
fi

# Bundle name.
if [ -z "$2" ]; then
    NAME="vc-partner-$ENVIRONMENT_LABEL-$APP_VERSION"
    echo "📦 Auto-generated name: $NAME"
else
    NAME="$2"
    echo "📦 Using provided name: $NAME"
fi

echo "  Environment: $ENVIRONMENT_LABEL"
echo "  App Version: $APP_VERSION"
echo "  Flavor: $ENVIRONMENT_LOWER"
echo "  Target: $TARGET_FILE"
echo ""

echo "🧹 Cleaning Flutter project..."
fvm flutter clean

echo "🗑️  Deleting pubspec.lock file..."
rm -f pubspec.lock

echo "📥 Running flutter pub get..."
fvm flutter pub get

echo "🔨 Running build_runner..."
fvm dart run build_runner build --delete-conflicting-outputs

echo "✨ Formatting code..."
fvm dart format .

echo ""
echo "🚀 Building app bundle for $ENVIRONMENT_LABEL environment..."
echo "   Command: fvm flutter build appbundle --flavor $ENVIRONMENT_LOWER -t $TARGET_FILE"
fvm flutter build appbundle --flavor "$ENVIRONMENT_LOWER" -t "$TARGET_FILE"

echo "✅ Verifying app bundle build..."
FLAVOR_AAB_PATH="build/app/outputs/bundle/${ENVIRONMENT_LOWER}Release/app-${ENVIRONMENT_LOWER}-release.aab"
DEFAULT_AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$FLAVOR_AAB_PATH" ]; then
    AAB_PATH="$FLAVOR_AAB_PATH"
    echo "Flavor app bundle found at $AAB_PATH"
elif [ -f "$DEFAULT_AAB_PATH" ]; then
    AAB_PATH="$DEFAULT_AAB_PATH"
    echo "Release app bundle found at $AAB_PATH"
else
    echo "❌ App bundle file not found! Listing bundle output directory:"
    ls -la build/app/outputs/bundle/
    exit 1
fi

NEW_AAB_NAME="$NAME.aab"
NEW_AAB_PATH="build/app/outputs/bundle/$NEW_AAB_NAME"
echo "📝 Copying app bundle to $NEW_AAB_NAME..."
echo "Copying from: $AAB_PATH"
echo "Copying to: $NEW_AAB_PATH"

if [ ! -f "$AAB_PATH" ]; then
    echo "❌ Source app bundle not found at $AAB_PATH"
    exit 1
fi

if cp "$AAB_PATH" "$NEW_AAB_PATH"; then
    echo "✅ App bundle copied to $NEW_AAB_PATH"
else
    echo "❌ Failed to copy app bundle"
    exit 1
fi

if [ ! -f "$NEW_AAB_PATH" ]; then
    echo "❌ Copied app bundle not found at $NEW_AAB_PATH"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$NEW_AAB_PATH" 2>/dev/null || stat -c%s "$NEW_AAB_PATH" 2>/dev/null || echo "0")
if [ "$FILE_SIZE" -eq "0" ]; then
    echo "❌ Copied app bundle is empty"
    exit 1
fi

echo ""
echo "✅ App bundle build completed successfully!"
echo "   Bundle: $NEW_AAB_NAME"
echo "   Path: $NEW_AAB_PATH"
echo "   Environment: $ENVIRONMENT_LABEL"
echo "   Version: $APP_VERSION"
