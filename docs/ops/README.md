# 🎮 VS Code Debugger Configuration

Your VS Code debugger is fully configured and ready to use!

## 🚀 Quick Start

1. **Press `F5`** to start debugging
2. **Select a configuration** from the dropdown (default: 🚀 Toolspace (Chrome))
3. **Start coding!**

## 📖 Documentation

- **[Full Debugger Guide](vscode-debugger-guide.md)** - Complete documentation with all features
- **[Quick Reference](debugger-quick-reference.md)** - Cheat sheet for common tasks
- **[Debug Service Error Fix](debug-service-error-fix.md)** - Info about the DebugService error

## ✅ What's Configured

### Launch Configurations

- ✅ 7 different debug configurations for various scenarios
- ✅ Chrome and macOS platform support
- ✅ Profile and Release modes
- ✅ Multi-platform compound launches

### Editor Settings

- ✅ Dart/Flutter specific settings optimized
- ✅ Format on save enabled
- ✅ Code actions on save
- ✅ Debug console configured
- ✅ File nesting for better organization

### Tasks

- ✅ Flutter development tasks (clean, build, test, analyze)
- ✅ GitHub automation tasks
- ✅ Workflow management tasks
- ✅ Custom scripts integration

### Scripts

- ✅ `flutter-run-clean.sh` - Filters DebugService errors from output

## 🎯 Most Common Workflows

### Daily Development

```
1. Press F5
2. Select: 🚀 Toolspace (Chrome)
3. Code and use hot reload (press 'r')
```

### Performance Testing

```
1. Press F5
2. Select: 📊 Toolspace (Profile)
3. Use DevTools profiler
```

### Production Build Test

```
1. Press F5
2. Select: 🎯 Toolspace (Release)
3. Test optimized build
```

### Clean Build

```
Cmd+Shift+P → Tasks: Run Task → 🔧 Flutter Clean & Get
```

## 🐛 Known Issue: DebugService Error

You may see this error in the console:

```
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
```

**This is harmless** - it's a Flutter SDK bug. Your code changes already minimize it, but for clean terminal output use:

```bash
./flutter-run-clean.sh -d chrome
```

See [debug-service-error-fix.md](debug-service-error-fix.md) for full details.

## 🆘 Need Help?

1. Check the [Quick Reference](debugger-quick-reference.md)
2. Read the [Full Guide](vscode-debugger-guide.md)
3. Run `flutter doctor -v` to check your setup

## 🔑 Key Files

```
.vscode/
├── launch.json       # Debug configurations ⭐
├── settings.json     # Editor settings
└── tasks.json        # Build/test tasks

docs/ops/
├── vscode-debugger-guide.md      # Full guide
├── debugger-quick-reference.md   # Cheat sheet
└── debug-service-error-fix.md    # Error explanation

flutter-run-clean.sh  # Clean output script
```

---

**Ready to debug?** Press `F5` and select **🚀 Toolspace (Chrome)**! 🎉
