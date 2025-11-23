# Firebase Setup - Quick Fix for Black Screen Issue

## The Problem
The app is stuck on a black screen because Firebase is not properly configured. The `google-services.json` file is missing.

## Quick Solution (To Test App Without Firebase)

If you want to test the app UI without Firebase first, you can temporarily disable Firebase:

1. **Comment out Firebase initialization in `lib/main.dart`:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Temporarily disabled for testing
     // try {
     //   await Firebase.initializeApp();
     // } catch (e) {
     //   debugPrint('Firebase initialization error: $e');
     // }
     
     runApp(const MyApp());
   }
   ```

2. **However, the app will crash when trying to use Firebase services.**

## Proper Solution (Set Up Firebase)

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: `roomi-app`
4. Follow the setup wizard

### Step 2: Add Android App
1. In Firebase Console, click "Add app" → Android
2. **Package name:** `com.example.roomi_real_final` (check `android/app/build.gradle.kts` line 24)
3. Download `google-services.json`
4. **Place it in:** `android/app/google-services.json`

### Step 3: Update build.gradle.kts

**File: `android/build.gradle.kts`** - Add at the end:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

**File: `android/app/build.gradle.kts`** - Add at the bottom (after the `flutter` block):
```kotlin
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Enable Firebase Services
1. **Authentication:** Firebase Console → Authentication → Enable Email/Password
2. **Firestore:** Firebase Console → Firestore Database → Create database (test mode)
3. **Storage:** Firebase Console → Storage → Get started (test mode)

### Step 5: Run Again
```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Firebase Options (FlutterFire CLI)

If you have FlutterFire CLI installed:
```bash
flutterfire configure
```

This will automatically generate the configuration files.

