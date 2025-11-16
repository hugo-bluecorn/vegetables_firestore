#!/bin/bash
set -euo pipefail

# Only run in Claude Code Web (remote environments)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "🎯 Setting up Dart environment for vegetables_firestore..."

# Check if Dart is already installed
if ! command -v dart &> /dev/null; then
  echo "📦 Installing Dart SDK..."

  # Define installation directory
  DART_INSTALL_DIR="$HOME/.dart-sdk"

  # Download and extract Dart SDK (latest stable)
  if [ ! -d "$DART_INSTALL_DIR" ]; then
    mkdir -p "$DART_INSTALL_DIR"
    cd /tmp
    echo "Downloading latest stable Dart SDK..."
    wget -q "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip" -O dart-sdk.zip
    unzip -q dart-sdk.zip
    mv dart-sdk/* "$DART_INSTALL_DIR/"
    rm -rf dart-sdk dart-sdk.zip
    echo "✅ Dart SDK downloaded and extracted"
  fi

  # Add Dart to PATH
  export PATH="$DART_INSTALL_DIR/bin:$PATH"
  echo "export PATH=\"$DART_INSTALL_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"

  echo "✅ Dart SDK installed successfully ($(dart --version 2>&1 | head -n1))"
else
  echo "✅ Dart SDK already installed ($(dart --version 2>&1 | head -n1))"
fi

# Navigate to project directory
cd "$CLAUDE_PROJECT_DIR"

# Install project dependencies
echo "📦 Installing project dependencies..."
dart pub get

# Generate mappable code
echo "🔨 Generating code with build_runner..."
dart run build_runner build --delete-conflicting-outputs

echo "✅ Dart environment setup complete!"
