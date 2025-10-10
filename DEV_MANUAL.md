# 🚀 Local Development - Manual Start

Since the automated script isn't working, here's the **manual way** (actually simpler!):

## Open 2 Terminals

### Terminal 1: Firebase Emulators

```powershell
cd E:\toolspace\toolspace
firebase emulators:start
```

Wait for: `✔ All emulators ready!`

### Terminal 2: Flutter Web

```powershell
cd E:\toolspace\toolspace
flutter run -d web-server --web-port 8080
```

Wait ~30 seconds for compilation, then browser opens automatically!

---

## That's It!

Two terminals, two commands. Done. ✅

### URLs

- **App**: http://localhost:8080
- **Emulator UI**: http://localhost:4000

### Hot Reload

In Terminal 2 (Flutter), press:

- `r` = Reload changes
- `R` = Full restart
- `q` = Quit

### Stop Everything

- Terminal 1: `Ctrl+C`
- Terminal 2: `Ctrl+C` or `q`

---

## Quick Start Script (Alternative)

If you want to try the automated version again:

```powershell
# Start emulators in background
Start-Process powershell -ArgumentList "-NoExit -Command firebase emulators:start"

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start Flutter
Start-Process powershell -ArgumentList "-NoExit -Command flutter run -d web-server --web-port 8080"
```

But honestly, **2 manual terminals is easier** and more reliable! 👍
