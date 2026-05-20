# 📱 Stepbystep — Mobile App

A cross-platform mobile application for flashcard-based learning, built with Flutter. Uses the same backend as the [Stepbystep web app](https://github.com/liorenline/Stepbystep).

---

## ✨ Features

- Create and manage flashcard decks
- Study mode with spaced repetition
- Personal account and progress tracking
- Works on Android, iOS, and desktop

---

## 🛠 Tech Stack

- **Framework:** Flutter / Dart
- **Backend:** Stepbystep API (Python / Flask + PostgreSQL)
- **Platforms:** Android, iOS, Linux, macOS, Windows, Web

---

## 🚀 Running locally

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (for mobile emulators)

### 1. Clone the repository

```bash
git clone https://github.com/liorenline/Stepbystep-application.git
cd Stepbystep-application
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
# Android / iOS
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

---

## 🔗 Related

- [Stepbystep Web App](https://github.com/liorenline/Stepbystep) — the backend and web frontend this app connects to

---

## 📁 Project Structure

```
Stepbystep-application/
├── android/       # Android-specific config
├── ios/           # iOS-specific config
├── linux/         # Linux desktop
├── macos/         # macOS desktop
├── windows/       # Windows desktop
├── web/           # Web build
├── lib/           # Main Flutter app code
├── test/          # Tests
└── pubspec.yaml   # Dependencies
```
