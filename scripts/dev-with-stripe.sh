#!/bin/bash

# Local Development with Stripe CLI
# This script helps you set up the local testing environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Local Development Setup with Stripe CLI  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check Stripe CLI
if ! command -v stripe &> /dev/null; then
    echo -e "${RED}✗ Stripe CLI not found${NC}"
    echo "Install it with: brew install stripe/stripe-cli/stripe"
    exit 1
fi

echo -e "${GREEN}✓ Stripe CLI found ($(stripe --version))${NC}"

# Check if logged in
if ! stripe config --list &> /dev/null; then
    echo -e "${YELLOW}! Not logged in to Stripe${NC}"
    echo "Running: stripe login"
    stripe login
else
    echo -e "${GREEN}✓ Already logged in to Stripe${NC}"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Local Testing Instructions         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}You need 4 terminals open:${NC}"
echo ""
echo -e "${GREEN}Terminal 1 - Firebase Emulators:${NC}"
echo "  firebase emulators:start"
echo ""
echo -e "${GREEN}Terminal 2 - Stripe CLI (webhook forwarding):${NC}"
echo "  stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook"
echo ""
echo -e "${GREEN}Terminal 3 - Flutter App:${NC}"
echo "  flutter run -d chrome"
echo ""
echo -e "${GREEN}Terminal 4 - Trigger Stripe Events:${NC}"
echo "  stripe trigger checkout.session.completed"
echo "  stripe trigger customer.subscription.created"
echo ""

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Important:${NC}"
echo "1. Start Terminal 1 first (emulators)"
echo "2. Start Terminal 2 and copy the webhook secret (whsec_...)"
echo "3. Add webhook secret to functions/.env:"
echo "   echo 'STRIPE_WEBHOOK_SECRET=whsec_...' >> functions/.env"
echo "4. Restart emulators (Ctrl+C in Terminal 1, then restart)"
echo "5. Start Terminals 3 and 4"
echo ""

read -p "Do you want to start the emulators now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}Starting Firebase emulators...${NC}"
    firebase emulators:start
fi
