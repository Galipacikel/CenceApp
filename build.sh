#!/bin/bash

# Flutter web build script for Vercel deployment

echo "Starting Flutter web build..."

# Install Flutter dependencies
echo "Installing Flutter dependencies..."
flutter pub get

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release

echo "Flutter web build completed successfully!"