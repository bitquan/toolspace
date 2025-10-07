# 🎯 VS Code Flutter Debugger - Quick Reference

## Launch Configurations

| Icon | Name                 | Use For               | Device |
| ---- | -------------------- | --------------------- | ------ |
| 🚀   | Toolspace (Chrome)   | **Daily development** | Chrome |
| 🖥️   | Toolspace (macOS)    | Desktop testing       | macOS  |
| 🧪   | Chrome - No DevTools | Fast iteration        | Chrome |
| 📊   | Profile              | Performance analysis  | Chrome |
| 🎯   | Release              | Production testing    | Chrome |
| 🐛   | Debug + Hot Reload   | Deep debugging        | Chrome |
| 🔧   | Custom Args          | Feature flags         | Chrome |
| 🎪   | Multi-Platform       | Cross-platform        | Both   |

## Keyboard Shortcuts

| Action            | Shortcut                |
| ----------------- | ----------------------- |
| Start Debugging   | `F5`                    |
| Start (No Debug)  | `Ctrl+F5`               |
| Stop              | `Shift+F5`              |
| Restart           | `Cmd+Shift+F5`          |
| Toggle Breakpoint | `F9`                    |
| Step Over         | `F10`                   |
| Step Into         | `F11`                   |
| Step Out          | `Shift+F11`             |
| Debug Console     | `Cmd+Shift+Y`           |
| Run Task          | `Cmd+Shift+P` → "Tasks" |

## Hot Commands (in Flutter terminal)

| Key | Action       |
| --- | ------------ |
| `r` | Hot reload   |
| `R` | Hot restart  |
| `h` | Help menu    |
| `d` | Detach       |
| `c` | Clear screen |
| `q` | Quit         |

## Quick Tasks

```bash
# Clean project
Cmd+Shift+P → Tasks: Run Task → 🧹 Flutter Clean

# Get dependencies
Cmd+Shift+P → Tasks: Run Task → 📦 Flutter Pub Get

# Run tests
Cmd+Shift+P → Tasks: Run Task → 🧪 Flutter Test

# Analyze code
Cmd+Shift+P → Tasks: Run Task → 🔍 Flutter Analyze
```

## Terminal Scripts

```bash
# Run with clean output (filters DebugService errors)
./flutter-run-clean.sh -d chrome

# Standard run
flutter run -d chrome

# Profile mode
flutter run -d chrome --profile

# Release mode
flutter run -d chrome --release
```

## Debug Panel Shortcuts

- **Variables**: Auto-shows current scope
- **Watch**: Add custom expressions
- **Call Stack**: See execution path
- **Breakpoints**: Manage all breakpoints

## Common Issues

| Problem             | Solution                                       |
| ------------------- | ---------------------------------------------- |
| DebugService errors | Use `flutter-run-clean.sh` or wait for SDK fix |
| No devices          | Run `flutter devices`                          |
| Hot reload fails    | Press `R` for full restart                     |
| Breakpoints ignored | Check you're in debug mode                     |

## File Locations

- **Launch configs**: `.vscode/launch.json`
- **Settings**: `.vscode/settings.json`
- **Tasks**: `.vscode/tasks.json`
- **Clean script**: `flutter-run-clean.sh`
- **Full guide**: `docs/ops/vscode-debugger-guide.md`

---

**Recommended for daily use**: 🚀 Toolspace (Chrome)
