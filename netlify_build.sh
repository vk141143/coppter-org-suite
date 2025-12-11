#!/usr/bin/env bash
set -e

# Install Flutter SDK if not cached
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Configure Flutter
flutter config --no-analytics
flutter precache --web

# Get dependencies and build
flutter pub get
flutter build web --release
