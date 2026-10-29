## Android Flavors – Commands Cheatsheet

This project uses **product flavors** (`dev`, `prod`) plus separate Dart entrypoints:
- `lib/main_dev.dart`  → `Environment.dev` → `env.dev`
- `lib/main_prod.dart` → `Environment.prod` → `env.prod`

All commands below assume you run them from the project root.

---

## Run App

### Dev

```bash
flutter run --flavor dev -t lib/main_dev.dart
# or (if you use fvm)
fvm flutter run --flavor dev -t lib/main_dev.dart
```

### Prod

```bash
flutter run --flavor prod -t lib/main_prod.dart
# or (if you use fvm)
fvm flutter run --flavor prod -t lib/main_prod.dart
```

---

## Build APK

### Dev APK

```bash
flutter build apk --flavor dev -t lib/main_dev.dart
# or
fvm flutter build apk --flavor dev -t lib/main_dev.dart
```

Expected output:
- `build/app/outputs/flutter-apk/app-dev-release.apk`

### Prod APK

```bash
flutter build apk --flavor prod -t lib/main_prod.dart
# or
fvm flutter build apk --flavor prod -t lib/main_prod.dart
```

Expected output:
- `build/app/outputs/flutter-apk/app-prod-release.apk`

---

## Build App Bundle (Play Store)

> Note: App bundle doesn’t require a target file; Flutter will use the correct
> one based on the flavor entrypoint you pass with `-t` if needed.

### Dev App Bundle

```bash
flutter build appbundle --flavor dev -t lib/main_dev.dart
# or
fvm flutter build appbundle --flavor dev -t lib/main_dev.dart
```

### Prod App Bundle

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart
# or
fvm flutter build appbundle --flavor prod -t lib/main_prod.dart
```

Expected output:
- `build/app/outputs/bundle/devRelease/app-dev-release.aab`
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

---

## send_apk.sh – Build & Upload APK to Slack

Script: `send_apk.sh`

The script:
- Cleans project, regenerates code, formats
- Builds **flavor-specific** APK
- Renames it to `vc-partner-<ENV>-<VERSION>.apk`
- Uploads to Slack using the configured token & channel

### Dev APK to Slack

```bash
./send_apk.sh dev
```

- Builds `dev` flavor using `lib/main_dev.dart`
- Auto names file: `vc-partner-DEV-<pubspec_version>.apk`
- Sends to Slack with default message:
  - `@Varsha @Razi VC partner DEV APK - v<version>`

With custom message:

```bash
./send_apk.sh dev "@Varsha DEV build for testing"
```

With custom name and message:

```bash
./send_apk.sh dev "@Varsha DEV RC" vc-partner-DEV-RC1
```

### Prod APK to Slack

```bash
./send_apk.sh prod
```

- Builds `prod` flavor using `lib/main_prod.dart`
- Auto names file: `vc-partner-PROD-<pubspec_version>.apk`

With custom message:

```bash
./send_apk.sh prod "@Varsha PROD release"
```

With custom name and message:

```bash
./send_apk.sh prod "@Varsha PROD RC" vc-partner-PROD-RC1
```

---

## Codegen & Lints (Common Before Release)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Or with fvm:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
```

---

## VS Code / Cursor Launch Configs

You can also use the predefined launch configs in `.vscode/launch.json`:
- `Dev (Debug)` / `Prod (Debug)`
- `Dev (Release)` / `Prod (Release)`

These internally call the same commands shown above.


