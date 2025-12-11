#!/usr/bin/env bash
set -euo pipefail

# Install Flutter if not cached
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

# Configure Flutter for web
flutter config --enable-web
flutter precache --web
flutter doctor -v

# Build the web app
flutter build web --release
