# ROOMI - Hostel/Room Finder App

A complete Flutter + Firebase mobile application for finding hostels and rooms near universities.

**Project Members:** Muhammad Ibrahim & Wajhi-ur-Rehman  
**University:** Bahria University Islamabad  
**Course:** Mobile Application Development (Semester Project)

## Features

### Public/Student Side (No Login Required)
- ✅ Splash Screen with smooth animations
- ✅ Onboarding (3 pages, skippable)
- ✅ Home Screen with search and filters
- ✅ Advanced filtering system:
  - Nearby Universities (multi-select)
  - Location/Area search
  - Gender filter (Boys/Girls/Unisex)
  - Budget slider (PKR 5,000 - PKR 50,000)
  - Room Type filter
  - Facilities filter (WiFi, Mess, Laundry, UPS, etc.)
- ✅ Hostel Detail Screen:
  - Image carousel (5-15 images)
  - Hostel information and facilities
  - Available rooms with pricing
  - Call & WhatsApp buttons
  - Reviews & Ratings section
- ✅ Review System:
  - Write reviews without login (name & phone optional)
  - 1-5 star ratings
  - View all reviews with time ago format

### Admin Side (Hostel Owner)
- ✅ Admin Login (Email/Password)
- ✅ Admin Dashboard:
  - List all hostels added by admin
  - Edit/Delete hostels
- ✅ Add/Edit Hostel (Multi-step form):
  - Step 1: Basic info (name, owner, phone, address, gender, universities)
  - Step 2: Add multiple rooms (dynamic list with facilities)
  - Step 3: Upload multiple photos
- ✅ Room Management:
  - Add/Edit/Delete rooms
  - Set rent per seat, total seats, available seats
  - Select facilities for each room

## Tech Stack

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Firebase** - Backend services:
  - Firebase Authentication (Email/Password for admins)
  - Cloud Firestore (Database)
  - Firebase Storage (Image storage)

## Firebase Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `roomi-app` (or your preferred name)
4. Follow the setup wizard

### 2. Add Android App

1. In Firebase Console, click "Add app" → Android
2. Register app:
   - **Package name:** `com.example.roomi_real_final` (check `android/app/build.gradle` for actual package name)
   - **App nickname:** ROOMI Android
   - **Debug signing certificate:** Optional
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 3. Add iOS App (Optional)

1. In Firebase Console, click "Add app" → iOS
2. Register app:
   - **Bundle ID:** Check `ios/Runner.xcodeproj` for actual bundle ID
   - **App nickname:** ROOMI iOS
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 4. Enable Firebase Services

#### Authentication
1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. Click "Save"

#### Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **test mode** (we'll add security rules later)
4. Choose a location (preferably closest to your region)
5. Click "Enable"

#### Storage
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Start in **test mode**
4. Choose a location (same as Firestore)
5. Click "Done"

### 5. Firestore Security Rules

Go to Firestore Database → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - anyone can read, only authenticated admins can write
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Hostels collection - anyone can read, only authenticated admins can write
    match /hostels/{hostelId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
      
      // Rooms subcollection
      match /rooms/{roomId} {
        allow read: if true;
        allow create, update, delete: if request.auth != null;
      }
      
      // Reviews subcollection - anyone can read and write
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if true;
        allow update, delete: if false;
      }
    }
  }
}
```

### 6. Storage Security Rules

Go to Storage → Rules and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /hostel_images/{hostelId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 7. Create First Admin User

You can create the first admin user manually:

1. Go to Firebase Console → Authentication
2. Click "Add user"
3. Enter email and password
4. Note the UID
5. Go to Firestore Database
6. Create a document in `users` collection with the UID as document ID:
   ```json
   {
     "email": "admin@example.com",
     "name": "Admin Name",
     "phone": "1234567890",
     "role": "admin"
   }
   ```

Alternatively, you can use the app's sign-up functionality (if implemented) or create via Firebase Console.

## Installation & Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)
- Firebase account

### Steps

1. **Clone or download the project**

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Add Firebase configuration files:**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/` (for iOS)

4. **Update package name (if needed):**
   - Check `android/app/build.gradle` for `applicationId`
   - Make sure it matches the package name in Firebase Console

5. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── constants.dart      # App constants
│   ├── theme.dart          # App theme (light/dark)
│   ├── utils.dart          # Utility functions
│   └── error.dart          # Custom exceptions
├── features/
│   ├── auth/               # Authentication (if needed)
│   ├── home/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   └── home_screen.dart
│   ├── hostel_detail/
│   │   └── hostel_detail_screen.dart
│   ├── admin/
│   │   ├── admin_login_screen.dart
│   │   ├── admin_dashboard.dart
│   │   └── add_hostel_screen.dart
│   ├── filters/
│   └── reviews/
│       ├── review_dialog.dart
│       └── review_list.dart
├── models/
│   ├── hostel_model.dart
│   ├── room_model.dart
│   ├── review_model.dart
│   └── user_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   └── storage_service.dart
├── widgets/
│   ├── hostel_card.dart
│   ├── filter_sheet.dart
│   ├── loading_widget.dart
│   └── error_widget.dart
└── main.dart
```

## Adding Sample Hostels

To add sample hostels for testing:

1. **Login as Admin:**
   - Use the admin credentials you created
   - Navigate to Admin Dashboard

2. **Add Hostel:**
   - Click the "+" button
   - Fill in the multi-step form:
     - Step 1: Enter hostel details
     - Step 2: Add at least one room
     - Step 3: Upload photos (5-15 images recommended)

3. **Sample Data Suggestions:**
   - Create 5 different hostels
   - Vary the locations (near different universities)
   - Add different room types and price ranges
   - Include various facilities

## Features Implementation Status

✅ All core features implemented:
- Public side (no login)
- Search and filtering
- Hostel details with reviews
- Admin side with full CRUD
- Multi-step hostel form
- Review system
- Image uploads
- Call & WhatsApp integration

## Dependencies

All dependencies are listed in `pubspec.yaml`. Key packages:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `provider` (state management)
- `image_picker`, `cached_network_image`, `carousel_slider`
- `flutter_rating_bar`
- `url_launcher`
- `intl`, `uuid`

## Notes

- The app uses Firebase for all backend services
- No local database required (except for caching images)
- All data is stored in Firestore
- Images are stored in Firebase Storage
- Reviews can be added without authentication
- Only admins can add/edit/delete hostels

## Troubleshooting

### Firebase not initialized
- Make sure `google-services.json` is in the correct location
- Run `flutter clean` and `flutter pub get`
- Rebuild the app

### Authentication errors
- Check if Email/Password is enabled in Firebase Console
- Verify admin user exists in Firestore `users` collection

### Image upload fails
- Check Storage security rules
- Verify Firebase Storage is enabled
- Check internet connection

## License

This project is created for educational purposes as part of the Mobile Application Development course at Bahria University Islamabad.

---

**Developed by:** Muhammad Ibrahim & Wajhi-ur-Rehman  
**Year:** 2024
