#!/bin/bash

# Firebase Project Setup Script
# Interactive setup for new Firebase project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Firebase Project Setup for Toolspace    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}✗ Firebase CLI not found${NC}"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

echo -e "${GREEN}✓ Firebase CLI found ($(firebase --version))${NC}"

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo -e "${YELLOW}! Not logged in to Firebase${NC}"
    echo "Running: firebase login"
    firebase login
else
    echo -e "${GREEN}✓ Already logged in to Firebase${NC}"
fi

echo ""
echo -e "${YELLOW}Current Firebase projects:${NC}"
firebase projects:list
echo ""

# Ask user what to do
echo -e "${BLUE}What would you like to do?${NC}"
echo "1. Create a NEW Firebase project"
echo "2. Use EXISTING project (gosenderr-6773f)"
echo "3. Exit and create project manually in console"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo -e "${YELLOW}Creating new Firebase project...${NC}"
        echo ""
        echo -e "${BLUE}Note: You'll need to create the project in Firebase Console first.${NC}"
        echo "Steps:"
        echo "1. Go to: https://console.firebase.google.com/"
        echo "2. Click 'Add project'"
        echo "3. Enter name: toolspace-prod (or your choice)"
        echo "4. Enable Google Analytics (recommended)"
        echo "5. Wait for creation"
        echo ""
        read -p "Press ENTER after you've created the project..."
        
        echo ""
        echo -e "${YELLOW}Refreshing project list...${NC}"
        firebase projects:list
        echo ""
        read -p "Enter your NEW project ID: " PROJECT_ID
        ;;
    2)
        echo -e "${YELLOW}Using existing project: gosenderr-6773f${NC}"
        PROJECT_ID="gosenderr-6773f"
        ;;
    3)
        echo -e "${BLUE}Opening Firebase Console...${NC}"
        open "https://console.firebase.google.com/"
        echo "Create your project, then run this script again."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✓ Using project: ${PROJECT_ID}${NC}"

# Create .firebaserc
echo ""
echo -e "${YELLOW}Creating .firebaserc...${NC}"
cat > .firebaserc << EOF
{
  "projects": {
    "default": "${PROJECT_ID}"
  }
}
EOF
echo -e "${GREEN}✓ .firebaserc created${NC}"

# Initialize Firebase if not already done
echo ""
echo -e "${YELLOW}Initializing Firebase...${NC}"
echo ""
echo -e "${BLUE}Select these features when prompted:${NC}"
echo "  ✓ Firestore"
echo "  ✓ Functions"
echo "  ✓ Hosting"
echo "  ✓ Storage"
echo "  ✓ Emulators"
echo ""
read -p "Press ENTER to start firebase init..."

firebase init

echo ""
echo -e "${GREEN}✓ Firebase initialized${NC}"

# FlutterFire configuration
echo ""
echo -e "${YELLOW}Configuring FlutterFire...${NC}"
echo ""

# Check if flutterfire is installed
if ! command -v flutterfire &> /dev/null; then
    echo -e "${YELLOW}! FlutterFire CLI not found. Installing...${NC}"
    dart pub global activate flutterfire_cli
    export PATH="$PATH":"$HOME/.pub-cache/bin"
fi

echo -e "${GREEN}✓ FlutterFire CLI ready${NC}"
echo ""
echo -e "${BLUE}Running flutterfire configure...${NC}"
echo "This will:"
echo "  • Connect to your Firebase project"
echo "  • Generate firebase_options.dart with real credentials"
echo "  • Configure platform-specific settings"
echo ""
read -p "Press ENTER to continue..."

flutterfire configure --project="${PROJECT_ID}"

echo ""
echo -e "${GREEN}✓ FlutterFire configured${NC}"

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Setup Complete! 🎉               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Project: ${PROJECT_ID}${NC}"
echo -e "${GREEN}✓ .firebaserc created${NC}"
echo -e "${GREEN}✓ Firebase initialized${NC}"
echo -e "${GREEN}✓ FlutterFire configured${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Enable services in Firebase Console:"
echo "   • Authentication (Email/Password, Google)"
echo "   • Firestore Database"
echo "   • Cloud Storage"
echo "   • Upgrade to Blaze plan (for Cloud Functions)"
echo ""
echo "2. Deploy Firestore rules:"
echo "   firebase deploy --only firestore:rules"
echo ""
echo "3. Deploy Cloud Functions:"
echo "   cd functions && npm install && npm run build"
echo "   firebase deploy --only functions"
echo ""
echo "4. Test with emulators:"
echo "   firebase emulators:start"
echo ""
echo -e "${BLUE}Open Firebase Console:${NC}"
echo "https://console.firebase.google.com/project/${PROJECT_ID}"
echo ""
echo -e "${GREEN}Setup complete!${NC}"
