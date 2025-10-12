#!/bin/bash

# Start Firebase Emulators for E2E Testing
# This script starts the Firebase emulator suite for local E2E testing

echo "🔥 Starting Firebase Emulators for E2E Testing..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Kill any existing emulator processes
echo "🧹 Cleaning up existing emulators..."
pkill -f "firebase" 2>/dev/null || true
pkill -f "java.*firestore" 2>/dev/null || true

# Wait a moment for processes to clean up
sleep 2

# Start the emulators
echo "🚀 Starting Firebase emulators..."
firebase emulators:start --only auth,firestore,functions &

# Wait for emulators to be ready
echo "⏳ Waiting for emulators to start..."
sleep 10

# Check if emulators are running
if curl -f http://localhost:9099/ >/dev/null 2>&1; then
    echo "✅ Auth emulator ready on port 9099"
else
    echo "❌ Auth emulator failed to start"
fi

if curl -f http://localhost:8081/ >/dev/null 2>&1; then
    echo "✅ Firestore emulator ready on port 8081"
else
    echo "❌ Firestore emulator failed to start"
fi

if curl -f http://localhost:5001/ >/dev/null 2>&1; then
    echo "✅ Functions emulator ready on port 5001"
else
    echo "❌ Functions emulator failed to start"
fi

echo "🎯 Firebase emulators are ready for E2E testing!"
echo "📋 Emulator URLs:"
echo "   - Auth: http://localhost:9099"
echo "   - Firestore: http://localhost:8081" 
echo "   - Functions: http://localhost:5001"
echo "   - UI: http://localhost:4000"
echo ""
echo "💡 Run 'npm run test:e2e' to start E2E tests with emulators"
