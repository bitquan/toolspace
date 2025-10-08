#!/bin/zsh
# Flutter run wrapper that filters out DebugService errors

flutter run "$@" 2>&1 | grep -v "DebugService: Error serving requests" | grep -v "Unsupported operation: Cannot send Null"
