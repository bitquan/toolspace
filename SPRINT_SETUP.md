# 🚀 Quick Start: Local Sprint Development

## Start Everything (One Command)

```powershell
.\dev-start.ps1
```

This opens:

- ✅ Firebase Emulators (2 PowerShell windows)
- ✅ Flutter Web Dev (1 PowerShell window)
- ✅ Browser tabs (App + Emulator UI)

---

## What You Get

| Service         | URL                   | Use For                  |
| --------------- | --------------------- | ------------------------ |
| **Your App**    | http://localhost:8080 | Main development         |
| **Emulator UI** | http://localhost:4000 | View auth/firestore data |

---

## Development Flow

###1. Start

```powershell
.\dev-start.ps1
```

### 2. Create Test User

1. Go to http://localhost:4000
2. Click **Authentication**
3. Add user: `test@test.com` / `test123`

### 3. Code & Test

- Edit `.dart` files
- Press `r` in Flutter window for hot reload
- Changes appear instantly!

### 4. Stop

- Close all PowerShell windows

---

## Hot Reload Commands

In the **Flutter** PowerShell window:

- `r` = Hot reload (instant updates)
- `R` = Hot restart (full restart)
- `q` = Quit

---

## Common Tasks

### Reset All Data

```powershell
Remove-Item .firebase -Recurse -Force
.\dev-start.ps1
```

### Just Emulators

```powershell
firebase emulators:start
```

### Just Flutter

```powershell
flutter run -d web-server --web-port 8080
```

---

## Sprint Workflow

```
Day 1:
  .\dev-start.ps1
  → Create test user
  → Work on Issue #110
  → Hot reload as you go
  → Close windows when done

Day 2:
  .\dev-start.ps1
  → Same test user still there!
  → Continue work
  → Test locally

Deploy:
  flutter build web --release
  firebase deploy
  git add . && git commit && git push
```

---

## Troubleshooting

### Port Already in Use

Close all PowerShell windows and try again

### Emulators Won't Start

```powershell
Get-Process | Where-Object { $_.ProcessName -like "*firebase*" } | Stop-Process -Force
.\dev-start.ps1
```

### Flutter Stuck

Close Flutter window, restart:

```powershell
flutter run -d web-server --web-port 8080
```

---

## That's It!

Three PowerShell windows = Complete dev environment

- Firebase window (emulators)
- Flutter window (hot reload)
- Launcher window (this closes after opening)

**Ready to sprint!** 🏃‍♂️💨
