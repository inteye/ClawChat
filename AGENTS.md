# AGENTS.md - ClawChat Development Guide

This guide is for AI coding agents working on the ClawChat Flutter project.

## 🚀 Build, Lint, and Test Commands

### Setup
```bash
# Install dependencies
flutter pub get

# Generate platform files (if needed)
flutter create .

# Generate code (Hive adapters, etc.)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build
```bash
# Build for specific platform
flutter build macos
flutter build ios
flutter build android
flutter build web

# Clean build
flutter clean && flutter pub get && flutter build macos
```

### Run
```bash
# Run on specific device
flutter run -d macos
flutter run -d ios
flutter run -d android

# Run with verbose output
flutter run -d macos --verbose
```

### Lint
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Check formatting
dart format --output=none --set-exit-if-changed lib/ test/
```

### Test
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/protocol_parser_test.dart

# Run single test by name
flutter test --plain-name "应该正确提取 agent 事件中的 delta 增量内容"

# Run tests with coverage
flutter test --coverage

# Run specific test with verbose output
flutter test test/websocket_connection_test.dart --verbose
```

## 📝 Code Style Guidelines

### Import Order
1. Dart SDK imports (`dart:*`)
2. Flutter imports (`package:flutter/*`)
3. Third-party packages (`package:*`)
4. Relative imports (`../`)

Example:
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive/hive.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../services/storage_service.dart';
```

### File Structure
```dart
/// File documentation
///
/// Brief description of the file's purpose
library;

// Imports (ordered as above)

// Constants (if any)

// Main class/function

// Helper classes/functions
```

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `chat_session_provider.dart`)
- **Classes**: `PascalCase` (e.g., `ChatSessionProvider`)
- **Variables/Functions**: `camelCase` (e.g., `sendMessage`)
- **Constants**: `camelCase` (e.g., `appVersion`) or `SCREAMING_SNAKE_CASE` for compile-time constants
- **Private members**: Prefix with `_` (e.g., `_handleMessage`)

### Type Annotations
- Always use explicit types for public APIs
- Use `var` or type inference for local variables when type is obvious
- Always specify return types for functions

```dart
// Good
Future<bool> sendMessage(String content) async { ... }
final messages = <Message>[];

// Avoid
sendMessage(content) { ... }
var messages = [];
```

### Error Handling
- Use try-catch for async operations
- Provide user-friendly error messages
- Log errors with context using `print()` (consider using a logging package in production)

```dart
try {
  await someOperation();
} catch (e) {
  print('❌ Operation failed: $e');
  state = state.copyWith(error: 'User-friendly message');
}
```

### State Management (Riverpod)
- Use `StateNotifier` for complex state
- Use `Provider` for simple dependencies
- Use `FutureProvider` for async data
- Always dispose resources in `dispose()`

### Comments and Documentation
- Use `///` for public API documentation
- Use `//` for implementation comments
- Avoid obvious comments - code should be self-documenting
- Use Chinese for user-facing strings and error messages
- Use English for code comments and documentation

### Async/Await
- Always use `async`/`await` instead of `.then()`
- Check `mounted` before using `BuildContext` after async operations
- Use `unawaited()` from `dart:async` for fire-and-forget operations

### Widget Best Practices
- Extract complex widgets into separate files
- Use `const` constructors when possible
- Prefer `StatelessWidget` over `StatefulWidget` when state is managed externally
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod

### Platform-Specific Code
- Use `Platform.isIOS`, `Platform.isAndroid`, etc. from `dart:io`
- Keep platform-specific code minimal and isolated
- Document platform differences

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models (Hive adapters)
├── providers/             # Riverpod state management
├── screens/               # Full-screen pages
├── services/              # Business logic (WebSocket, storage, etc.)
├── utils/                 # Utilities and helpers
└── widgets/               # Reusable UI components
```

## 🔧 Key Technologies

- **State Management**: Riverpod 2.x
- **Local Storage**: Hive 2.x
- **WebSocket**: web_socket_channel
- **UI**: Flutter Material Design 3

## ⚠️ Important Notes

- Platform files (android/, ios/, macos/, etc.) are NOT in version control
- Generated files (*.g.dart) are NOT in version control
- Always run `flutter create .` after cloning
- Use `flutter pub run build_runner build` to generate code
- Messages are stored locally with Hive and sorted by timestamp
- WebSocket uses OpenClaw Gateway protocol with challenge-response auth

## 🐛 Debugging

- Use `print()` with emoji prefixes for visibility (e.g., `print('✅ Success')`)
- Check logs with `flutter logs`
- Use `--verbose` flag for detailed output
- For network issues, check platform-specific permissions (Info.plist, AndroidManifest.xml)

## 📚 References

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Project README](README.md)
- [Platform Setup Guide](docs/PLATFORM_SETUP.md)
