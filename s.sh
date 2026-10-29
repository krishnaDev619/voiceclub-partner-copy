#!/bin/bash
# Build and send APK to Slack using Flutter product flavors
#
# Usage:
#   ./s.sh dev                           # Build and send DEV APK
#   ./s.sh prod                          # Build and send PROD APK
#   ./s.sh dev "Custom message"          # Build and send DEV APK with custom message
#   ./s.sh prod "Custom message"         # Build and send PROD APK with custom message
#   ./s.sh dev "Custom message" my-apk   # Build and send DEV APK with custom name and message

# Slack token needs files:write. Set SLACK_API_TOKEN in the environment,
# or put it in a gitignored .env.local file.
CHANNEL_ID="C05FMNY20DA"

# Exit on error
set -e

if [ -z "${SLACK_API_TOKEN:-}" ] && [ -f .env.local ]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

if [ -z "${SLACK_API_TOKEN:-}" ]; then
  echo "SLACK_API_TOKEN is not set. Export it or add it to .env.local"
  exit 1
fi

# Parse environment argument
ENVIRONMENT="${1:-prod}"
ENVIRONMENT_LOWER=$(echo "$ENVIRONMENT" | tr '[:upper:]' '[:lower:]')

if [ "$ENVIRONMENT_LOWER" != "dev" ] && [ "$ENVIRONMENT_LOWER" != "prod" ]; then
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: ./s.sh <dev|prod> [message] [custom_name]"
    echo ""
    echo "Examples:"
    echo "  ./s.sh dev                    # Build DEV APK"
    echo "  ./s.sh prod                   # Build PROD APK"
    echo "  ./s.sh dev \"@Varsha DEV APK\" # Build DEV APK with custom message"
    exit 1
fi

# Set the target file based on environment
if [ "$ENVIRONMENT_LOWER" = "dev" ]; then
    TARGET_FILE="lib/main_dev.dart"
    ENVIRONMENT_LABEL="DEV"
else
    TARGET_FILE="lib/main_prod.dart"
    ENVIRONMENT_LABEL="PROD"
fi

# Read APP_VERSION from pubspec.yaml (source of truth for package_info_plus)
PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Warning: pubspec.yaml not found, using 'unknown' for version"
    APP_VERSION="unknown"
else
    # Extract version from pubspec.yaml (format: version: 8.7.9+193)
    APP_VERSION=$(grep -E "^version:" "$PUBSPEC_FILE" | sed 's/version:[[:space:]]*//' | cut -d'+' -f1 | tr -d ' ')

    if [ -z "$APP_VERSION" ]; then
        echo "Warning: Could not read version from pubspec.yaml, using 'unknown'"
        APP_VERSION="unknown"
    fi
fi

# Auto-generate APK name or use provided argument
if [ -z "$3" ]; then
    NAME="vc-partner-$ENVIRONMENT_LABEL-$APP_VERSION"
    echo "📦 Auto-generated name: $NAME"
else
    NAME="$3"
    echo "📦 Using provided name: $NAME"
fi

echo "  Environment: $ENVIRONMENT_LABEL"
echo "  App Version: $APP_VERSION"
echo "  Flavor: $ENVIRONMENT_LOWER"
echo "  Target: $TARGET_FILE"
echo ""

# Check if a custom message is provided as an argument
if [ -z "$2" ]; then
    echo "No custom message provided, using default message."
    MESSAGE="@Varsha @Razi VC Partner $ENVIRONMENT_LABEL APK - v$APP_VERSION"
else
    MESSAGE="$2"
    echo "Using custom message: $MESSAGE"
fi

# Step 1: Clean Flutter project
echo ""
echo "🧹 Cleaning Flutter project..."
fvm flutter clean

# Step 2: Delete pubspec.lock file
echo "🗑️  Deleting pubspec.lock file..."
rm -f pubspec.lock

# Step 3: Run flutter pub get
echo "📥 Running flutter pub get..."
fvm flutter pub get

# Step 4: Run build_runner
echo "🔨 Running build_runner..."
fvm dart run build_runner build --delete-conflicting-outputs

echo "✨ Formatting code..."
fvm dart format .

# Step 5: Build APK with flavor and target
echo ""
echo "🚀 Building APK for $ENVIRONMENT_LABEL environment..."
echo "   Command: fvm flutter build apk --flavor $ENVIRONMENT_LOWER -t $TARGET_FILE"
fvm flutter build apk --flavor $ENVIRONMENT_LOWER -t $TARGET_FILE

# Verify that the build succeeded
echo "✅ Verifying APK build..."
# Check for expected APK path (flavor builds have different output paths)
FLAVOR_APK_PATH="build/app/outputs/flutter-apk/app-$ENVIRONMENT_LOWER-release.apk"
DEFAULT_APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$FLAVOR_APK_PATH" ]; then
    APK_PATH="$FLAVOR_APK_PATH"
    echo "Flavor APK found at $APK_PATH"
elif [ -f "$DEFAULT_APK_PATH" ]; then
    APK_PATH="$DEFAULT_APK_PATH"
    echo "Release APK found at $APK_PATH"
else
    echo "APK file not found! Listing contents of the output directory:"
    ls -la build/app/outputs/flutter-apk/
    exit 1
fi

# Step 6: Rename APK file
NEW_APK_NAME="$NAME.apk"
NEW_APK_PATH="build/app/outputs/flutter-apk/$NEW_APK_NAME"
echo "📝 Renaming APK to $NEW_APK_NAME..."
echo "Copying from: $APK_PATH"
echo "Copying to: $NEW_APK_PATH"

# Verify source file exists
if [ ! -f "$APK_PATH" ]; then
    echo "Error: Source APK file not found at $APK_PATH"
    exit 1
fi

# Copy the file
if cp "$APK_PATH" "$NEW_APK_PATH"; then
    echo "APK successfully copied to $NEW_APK_PATH"
else
    echo "Error: Failed to copy APK file"
    exit 1
fi

# Verify the copied file exists and has size > 0
if [ ! -f "$NEW_APK_PATH" ]; then
    echo "Error: Renamed APK file not found at $NEW_APK_PATH"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$NEW_APK_PATH" 2>/dev/null || stat -c%s "$NEW_APK_PATH" 2>/dev/null || echo "0")
if [ "$FILE_SIZE" -eq "0" ]; then
    echo "Error: Renamed APK file is empty"
    exit 1
fi

echo "APK file verified: $NEW_APK_PATH (size: $FILE_SIZE bytes)"

# Step 7: Send the APK to Slack using new two-step API
echo ""
echo "📤 Sending APK to Slack using new API methods..."

# Step 7a: Get upload URL from Slack
echo "Getting upload URL from Slack..."
UPLOAD_URL_RESULT=$(curl -s -H "Authorization: Bearer $SLACK_API_TOKEN" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "filename=$NEW_APK_NAME" \
    -d "length=$FILE_SIZE" \
    "https://slack.com/api/files.getUploadURLExternal")

echo "Upload URL Response: $UPLOAD_URL_RESULT"

# Check if we got a valid upload URL
if ! echo "$UPLOAD_URL_RESULT" | grep -q '"ok":true'; then
    echo "Failed to get upload URL from Slack. Response: $UPLOAD_URL_RESULT"
    exit 1
fi

# Extract upload URL and file ID
UPLOAD_URL=$(echo "$UPLOAD_URL_RESULT" | grep -o '"upload_url":"[^"]*"' | cut -d'"' -f4 | sed 's/\\//g')
FILE_ID=$(echo "$UPLOAD_URL_RESULT" | grep -o '"file_id":"[^"]*"' | cut -d'"' -f4)

echo "Upload URL: $UPLOAD_URL"
echo "File ID: $FILE_ID"

# Step 7b: Upload file to the provided URL (with timeout and progress)
echo "Uploading file to provided URL... This may take several minutes for large files."
FILE_UPLOAD_RESULT=$(curl --connect-timeout 30 --max-time 600 --progress-bar -X POST \
    -F file=@$NEW_APK_PATH \
    "$UPLOAD_URL")

echo "File upload response: $FILE_UPLOAD_RESULT"

# Step 7c: Complete the upload process
echo "Completing upload process..."
COMPLETE_RESULT=$(curl -s -H "Authorization: Bearer $SLACK_API_TOKEN" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "files=[{\"id\":\"$FILE_ID\",\"title\":\"$NEW_APK_NAME\"}]" \
    -d "channel_id=$CHANNEL_ID" \
    -d "initial_comment=$MESSAGE" \
    "https://slack.com/api/files.completeUploadExternal")

echo "Complete upload response: $COMPLETE_RESULT"

# Check final result
if echo "$COMPLETE_RESULT" | grep -q '"ok":true'; then
    echo ""
    echo "✅ File uploaded successfully to Slack!"
    echo "   APK: $NEW_APK_NAME"
    echo "   Environment: $ENVIRONMENT_LABEL"
    echo "   Version: $APP_VERSION"
else
    echo "Failed to complete file upload to Slack. Response: $COMPLETE_RESULT"
    exit 1
fi
