# VS Code Debugger Configuration Guide

## 📋 Overview

Your VS Code debugger is now fully configured with multiple launch configurations for different debugging scenarios.

## 🚀 Available Launch Configurations

### 1. **🚀 Toolspace (Chrome)** - Main Development

- **Best for**: Daily development on web
- **Device**: Chrome browser
- **Features**:
  - Hot reload enabled
  - VM service error suppression
  - DevTools available
- **Use when**: You're developing and testing web features

### 2. **🖥️ Toolspace (macOS)** - Desktop Testing

- **Best for**: Testing on macOS desktop
- **Device**: macOS native app
- **Features**:
  - Native performance
  - Desktop-specific features
- **Use when**: Testing desktop app behavior

### 3. **🧪 Toolspace (Chrome - No DevTools)** - Clean Debug

- **Best for**: Debugging without DevTools overhead
- **Device**: Chrome browser
- **Features**:
  - No DevTools = faster startup
  - Cleaner console output
- **Use when**: You don't need DevTools and want faster iteration

### 4. **📊 Toolspace (Profile)** - Performance Testing

- **Best for**: Performance profiling
- **Device**: Chrome browser
- **Mode**: Profile mode (optimized + profiling info)
- **Use when**: Analyzing performance bottlenecks

### 5. **🎯 Toolspace (Release)** - Production Testing

- **Best for**: Testing production build
- **Device**: Chrome browser
- **Mode**: Release mode (fully optimized)
- **Use when**: Verifying production behavior

### 6. **🐛 Toolspace (Debug + Hot Reload)** - Advanced Debugging

- **Best for**: Deep debugging with breakpoints
- **Device**: Chrome browser
- **Features**:
  - Pause on start
  - Full VM service access
- **Use when**: Need to debug app initialization or use advanced debugging

### 7. **🔧 Toolspace (Custom Args)** - Custom Configuration

- **Best for**: Testing with custom configuration
- **Device**: Chrome browser
- **Features**:
  - Custom dart-define variables
  - Configurable behavior
- **Use when**: Testing feature flags or custom builds

### 8. **🎪 Multi-Platform Test** - Compound Launch

- **Best for**: Testing across platforms simultaneously
- **Devices**: Chrome + macOS
- **Use when**: You need to verify behavior on multiple platforms

## 🎮 How to Use

### From VS Code UI:

1. Press `F5` or click the **Run and Debug** icon (▶️) in the sidebar
2. Select your desired configuration from the dropdown
3. Press the green play button

### From Command Palette:

1. Press `Cmd+Shift+P`
2. Type "Debug: Select and Start Debugging"
3. Choose your configuration

### Keyboard Shortcuts:

- `F5` - Start debugging with current configuration
- `Ctrl+F5` - Start without debugging (run mode)
- `Shift+F5` - Stop debugging
- `Cmd+Shift+F5` - Restart debugging
- `F9` - Toggle breakpoint
- `F10` - Step over
- `F11` - Step into
- `Shift+F11` - Step out

## 🔧 VS Code Tasks Available

Quick tasks you can run from Command Palette (`Cmd+Shift+P` → "Tasks: Run Task"):

### Flutter Development:

- **🧹 Flutter Clean** - Clean build artifacts
- **📦 Flutter Pub Get** - Get dependencies
- **🔧 Flutter Clean & Get** - Clean and get dependencies
- **🔍 Flutter Analyze** - Run static analysis
- **🧪 Flutter Test** - Run all tests
- **🏃 Flutter Run (Chrome)** - Run app in Chrome
- **🖥️ Flutter Run (macOS)** - Run app on macOS
- **📱 Flutter Devices** - List available devices
- **🚀 Flutter Doctor** - Check environment setup
- **📊 Flutter Build Web** - Build for web deployment

### GitHub/Project Management:

- **Assign Issue to Copilot** - Assign GitHub issue to Copilot
- **Create Issue** - Create new GitHub issue
- **Approve Copilot PRs** - Approve Copilot pull requests
- **Workflow Cleanup** - Clean up GitHub Actions workflows

## 🐛 Debugging Tips

### Setting Breakpoints:

1. Click in the gutter (left of line numbers) to set a breakpoint
2. Right-click on a breakpoint for conditional/logpoint options
3. Use `debugger;` statement in code for programmatic breakpoints

### Debug Console:

- Access via `Cmd+Shift+Y` or Debug Console tab
- Evaluate expressions while paused
- Example: Type `myVariable.toString()` to inspect values

### Watch Expressions:

- Add expressions to Watch panel to track values
- Updates automatically during debugging
- Right-click to add, edit, or remove

### Call Stack:

- See the current execution path
- Click on any frame to jump to that context
- Useful for understanding how you got to current point

## 🎯 Best Practices

### 1. **Start Simple**

Use **🚀 Toolspace (Chrome)** for most development work.

### 2. **Profile Before Optimizing**

Switch to **📊 Toolspace (Profile)** mode when investigating performance issues.

### 3. **Test Release Builds**

Periodically run **🎯 Toolspace (Release)** to catch issues that only appear in optimized builds.

### 4. **Use No DevTools for Speed**

When you don't need DevTools, **🧪 Toolspace (Chrome - No DevTools)** starts faster.

### 5. **Multi-Platform Testing**

Use **🎪 Multi-Platform Test** compound to catch platform-specific issues early.

## ⚙️ Configuration Files

### `.vscode/launch.json`

- Debug configurations
- Device selection
- Launch arguments
- VM options

### `.vscode/settings.json`

- Editor settings
- Dart/Flutter specific settings
- Debug console configuration
- File associations

### `.vscode/tasks.json`

- Build tasks
- Test tasks
- Custom scripts
- GitHub automation

## 🚨 Known Issues

### DebugService Error

```
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
```

**Status**: This is a known Flutter SDK bug (v3.35.2) with web debugging.

**Impact**: Annoying console spam, but doesn't affect app functionality.

**Workarounds**:

1. ✅ Error filtering in our code (already implemented)
2. ✅ Use the **flutter-run-clean.sh** script (filters terminal output)
3. ✅ Use **🧪 No DevTools** configuration (reduces frequency)
4. ⏳ Wait for Flutter SDK fix (future release)

**To use the clean script**:

```bash
./flutter-run-clean.sh -d chrome
```

## 📚 Additional Resources

- [Flutter Debugging Docs](https://docs.flutter.dev/testing/debugging)
- [VS Code Dart Debugging](https://dartcode.org/docs/debugging/)
- [DevTools Guide](https://docs.flutter.dev/tools/devtools/overview)
- [Hot Reload Best Practices](https://docs.flutter.dev/tools/hot-reload)

## 🆘 Troubleshooting

### "Could not find Chrome"

- Install Google Chrome
- Or use macOS configuration instead

### "No device found"

Run: `flutter devices` to see available devices

### Hot Reload Not Working

- Press `r` in the terminal
- Or use `Cmd+Shift+F5` to restart

### Breakpoints Not Hitting

- Make sure you're in Debug mode (not Release)
- Check that code is actually executed
- Try Clean & Get Dependencies

### DevTools Not Opening

- Check if port 9100 is available
- Or use **🧪 No DevTools** configuration

## 💡 Pro Tips

1. **Use Hot Reload** (`r` key) instead of full restart when possible
2. **Add `debugger;`** statements for quick breakpoints
3. **Use Flutter Inspector** in DevTools to debug UI layout issues
4. **Profile in Release mode** for accurate performance metrics
5. **Check `.dart_tool/` logs** if something seems wrong with the build

---

**Last Updated**: October 6, 2025  
**Flutter Version**: 3.35.2  
**Dart Version**: 3.9.0
