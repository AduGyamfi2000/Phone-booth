# Phone Booth

A Flutter MVP for a localized skill-sharing marketplace using Firebase, geolocation, and Provider.

## Features

- Unified `UserProfile` model with skills, bio, location, and contact info
- Location-based discovery within a 5km–20km radius
- Toggle between list discovery and map discovery
- Multi-step profile creation with photo upload and skill management
- Direct contact via phone and email
- Offline-first caching with Firestore persistence and local profile storage

## Setup

1. Install Flutter and the Dart SDK.
2. Add Firebase configuration files for Android and iOS in the appropriate platform folders.
3. Run:

```bash
flutter pub get
```

4. Launch the app:

```bash
flutter run
```

## Notes

- The app uses `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `geolocator`, and `google_maps_flutter`.
- Replace Firebase project settings with your own values or generated `firebase_options.dart` if needed.
