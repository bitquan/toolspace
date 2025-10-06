# Password Generator

A secure, client-side password generator with customizable rules and real-time entropy calculation.

## Features

- **Length Slider**: Adjustable from 8 to 128 characters
- **Character Sets**: Toggle uppercase, lowercase, digits, and symbols
- **Ambiguous Character Filter**: Optional exclusion of 0, O, 1, l, I
- **Entropy Meter**: Real-time password strength calculation with visual feedback
- **Single Generation**: Generate one password at a time
- **Batch Generation**: Generate 20 passwords at once
- **Copy Operations**: Copy individual or all passwords

## Architecture

- **Frontend Only**: Pure Flutter/Dart implementation
- **Cryptographically Secure**: Uses `Random.secure()` for strong randomness
- **Privacy First**: All generation happens client-side, nothing sent to server

## Status

✅ **Implemented** - Full feature set complete with tests

## Getting Started

This tool is accessible at `/tools/password-gen` in the main Toolspace app, or via the Password Generator card on the home screen.

## Implementation Details

### Core Logic
- `logic/password_generator.dart`: Password generation, entropy calculation, strength assessment

### UI
- `password_gen_screen.dart`: Main screen with Material 3 design and animations

### Tests
- Unit tests: `test/tools/password_gen/password_generator_test.dart`
- Widget tests: `test/tools/password_gen/password_gen_widget_test.dart`

## Security

- Uses Dart's cryptographically secure random number generator
- Passwords are never transmitted or stored
- Entropy calculations follow industry standards
- Strength thresholds based on NIST guidelines

## Documentation

Full documentation available at `docs/tools/password-gen.md`
