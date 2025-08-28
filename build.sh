#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting Flutter Web build for Vercel"

# --- Caching setup (speeds up subsequent builds on Vercel) ---
CACHE_DIR="${VERCEL_CACHE_DIR:-.vercel/cache}"
FLUTTER_DIR="$CACHE_DIR/flutter"
PUB_CACHE_DIR="$CACHE_DIR/pub-cache"
mkdir -p "$CACHE_DIR" "$PUB_CACHE_DIR"
export PUB_CACHE="$PUB_CACHE_DIR"

# --- Fetch or update Flutter SDK ---
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "==> Fetching Flutter SDK (stable) into $FLUTTER_DIR"
  rm -rf "$FLUTTER_DIR"
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  echo "==> Using cached Flutter SDK at $FLUTTER_DIR"
  (cd "$FLUTTER_DIR" && git fetch --depth 1 origin stable >/dev/null 2>&1 || true && git checkout -f stable >/dev/null 2>&1 || true)
fi

# Put Flutter on PATH for this build
export PATH="$FLUTTER_DIR/bin:$PATH"

# Diagnostics (safe if flutter exists)
flutter --version || true

# Enable web + precache web artifacts
flutter config --enable-web
flutter precache --web

# Install Dart/Flutter dependencies
flutter pub get

# Build for web
BUILD_DIR="build/web"
echo "==> Building Flutter web app into $BUILD_DIR"
flutter build web --release --no-tree-shake-icons

# Verify the output exists
if [ ! -d "$BUILD_DIR" ] || [ ! -f "$BUILD_DIR/index.html" ]; then
  echo "ERROR: Expected output directory '$BUILD_DIR' with index.html is missing."
  ls -la build || true
  exit 1
fi

# Some Vercel setups may still look for `web` as output; mirror build into ./web (safe on ephemeral build env)
# NOTE: Project repo already has a source `web/` folder. We overwrite it only in CI build workspace.
if [ -d "web" ]; then
  echo "==> Mirroring build output into ./web for compatibility"
  rm -rf web/*
  cp -R "$BUILD_DIR"/. web/
fi

# Final confirmation
echo "==> Build completed successfully. Output at $BUILD_DIR"
ls -la "$BUILD_DIR" | head -n 50