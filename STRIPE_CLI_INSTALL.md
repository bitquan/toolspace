# Stripe CLI Installation Guide

## ⚠️ Stripe CLI Not Found

The Stripe CLI is required to test billing webhooks locally. Here's how to install it:

## Option 1: Chocolatey (Easiest - Requires Admin)

1. **Open PowerShell as Administrator:**

   - Press Windows key
   - Type "PowerShell"
   - Right-click "Windows PowerShell"
   - Select "Run as Administrator"

2. **Install Stripe CLI:**

   ```powershell
   choco install stripe-cli -y
   ```

3. **Verify installation:**
   ```powershell
   stripe --version
   ```

## Option 2: Manual Installation (No Admin Required)

1. **Download Stripe CLI:**

   - Go to: https://github.com/stripe/stripe-cli/releases/latest
   - Download: `stripe_X.X.X_windows_x86_64.zip` (replace X.X.X with version)

2. **Extract the ZIP:**

   - Create a folder: `C:\stripe-cli\` (or any location you prefer)
   - Extract the `stripe.exe` file to that folder

3. **Add to PATH:**

   - Press `Windows + R`
   - Type: `sysdm.cpl` and press Enter
   - Go to "Advanced" tab → "Environment Variables"
   - Under "User variables", select "Path" → "Edit"
   - Click "New" and add: `C:\stripe-cli`
   - Click "OK" on all windows

4. **Restart PowerShell** and verify:
   ```powershell
   stripe --version
   ```

## After Installation

Once Stripe CLI is installed, you need to login:

```powershell
stripe login
```

This will open your browser and ask you to authorize the CLI. Use your Stripe test account credentials.

## Next Steps

After installing Stripe CLI, return to `LOCAL_DEV_GUIDE.md` to start the full development environment.

---

**Current Status:**

- ✅ Flutter SDK installed
- ✅ Firebase CLI installed (v14.18.0)
- ✅ Stripe keys configured (backend + frontend)
- ❌ **Stripe CLI needs installation** ← You are here
