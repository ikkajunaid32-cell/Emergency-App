# Emergency Response Mobile Application

<p align="center">
  <img src="assets/logos/emergencyAppLogo.png" width="120" alt="Emergency App Logo" />
</p>

An intelligent, cross-platform emergency response mobile application built with **Flutter**, **Firebase**, **SQLite local fallback**, and **Google Maps API**. The application bridges citizens in distress with specialized emergency first responders (Police, Firefighters, Ambulances/Paramedics) in real-time with automated location broadcasts and live video assessment.

---

## 🚀 Key Features

- **🆘 Instant SOS Distress Alerts**: Broadcast real-time GPS location and emergency details to active responders and trusted emergency contacts via SMS.
- **🛰️ Live Incident Mapping & Routing**: Integrated Google Maps navigation for responders with direct turn-by-turn route launching.
- **📹 Live Video Streaming**: Real-time video feeds during active emergencies for situational awareness and remote assessment.
- **👥 Role-Based Dispatch & Responder Consoles**: Dedicated interfaces for Citizens, Police, Firefighters, and Ambulances with duty availability toggles.
- **🎨 Modern Design System**: Refreshed UI layout with cohesive typography (`GoogleFonts.poppins` & `GoogleFonts.inter`), rounded card surfaces, accessible touch targets, and fresh brand logo and Android launcher icons.
- **💾 Offline SQLite Local Caching**: Resilient incident management and responder status synchronization even during network transitions.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.27+ (Dart 3.6+)
- **State Management & Navigation**: GetX
- **Backend & Realtime**: Firebase Auth, Firebase Realtime Database, Cloud Firestore
- **Local Persistence**: SQLite (`sqflite`), `shared_preferences`
- **Location & Mapping**: `geolocator`, Google Maps API, `url_launcher`
- **Live Video**: ZEGOCLOUD UIKit Prebuilt Live Streaming
- **UI & Typography**: `google_fonts`, Material 3 design principles

---

## 📦 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0 <4.0.0`
- Android Studio / Android SDK (API 34+)

### Installation
```bash
# Clone the repository
git clone https://github.com/ikkajunaid32-cell/Emergency-App.git

# Enter project directory
cd Emergency-App

# Fetch dependencies
flutter pub get

# Run static analysis
dart analyze

# Run unit & widget tests
flutter test

# Run the app
flutter run
```

### Prebuilt APK
The compiled debug APK is available directly at `EmergencyApp.apk` or can be generated anytime using:
```powershell
flutter build apk --debug --android-skip-build-dependency-validation
```
