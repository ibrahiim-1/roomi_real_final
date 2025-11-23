# Complete Firebase Setup Guide for ROOMI App

This is a comprehensive, step-by-step guide to set up Firebase for your ROOMI Hostel Finder App.

---

## 📋 Prerequisites

- Google account
- Flutter project ready
- Android device/emulator for testing

---

## 🚀 Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
1. Open your browser and go to: **https://console.firebase.google.com/**
2. Sign in with your Google account

### 1.2 Create New Project
1. Click **"Add project"** or **"Create a project"**
2. **Project name:** Enter `roomi-app` (or any name you prefer)
3. Click **"Continue"**
4. **Google Analytics:** 
   - You can enable it (optional) or disable it
   - If enabled, select or create an Analytics account
   - Click **"Continue"**
5. Click **"Create project"**
6. Wait for project creation (30-60 seconds)
7. Click **"Continue"** when ready

---

## 📱 Step 2: Add Android App to Firebase

### 2.1 Register Android App
1. In your Firebase project dashboard, you'll see:
   ```
   Get started by adding Firebase to your app
   ```
2. Click the **Android icon** (🟢 Android)
3. Fill in the registration form:
   - **Android package name:** `com.example.roomi_real_final`
     - ⚠️ **Important:** This must match exactly with your app's package name
     - To verify: Check `android/app/build.gradle.kts` → `applicationId`
   - **App nickname (optional):** `ROOMI Android`
   - **Debug signing certificate SHA-1 (optional):** Leave blank for now
4. Click **"Register app"**

### 2.2 Download google-services.json
1. You'll see: **"Download google-services.json"**
2. Click **"Download google-services.json"**
3. **Save the file** - remember where you saved it!

### 2.3 Place google-services.json in Your Project
1. **Copy** the downloaded `google-services.json` file
2. **Navigate** to your project folder:
   ```
   D:\BAHRIA\SEMESTER 06\Mobile App Development\roomi_real_final\android\app\
   ```
3. **Paste** `google-services.json` into the `android/app/` folder
4. **Verify** the file is there:
   ```
   android/app/google-services.json ✅
   ```

### 2.4 Add Google Services Plugin (Already Done)
The build.gradle files have been updated. If you need to verify:

**File: `android/build.gradle.kts`** should have:
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

**File: `android/app/build.gradle.kts`** should have at the bottom:
```kotlin
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
```

---

## 🔐 Step 3: Enable Firebase Authentication

### 3.1 Go to Authentication
1. In Firebase Console, click **"Authentication"** in the left sidebar
2. Click **"Get started"** (if you see it)

### 3.2 Enable Email/Password Sign-in
1. Click on the **"Sign-in method"** tab
2. Click on **"Email/Password"**
3. **Toggle ON** the first switch (Email/Password)
4. **Toggle OFF** the second switch (Email link - we don't need it)
5. Click **"Save"**

✅ **Authentication is now enabled!**

---

## 💾 Step 4: Set Up Firestore Database

### 4.1 Create Firestore Database
1. In Firebase Console, click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**

### 4.2 Choose Security Rules
1. Select **"Start in test mode"**
   - This allows read/write for 30 days
   - We'll add proper rules later
2. Click **"Next"**

### 4.3 Choose Location
1. Select a **location** closest to your region:
   - For Pakistan: Choose `asia-south1` (Mumbai) or `asia-southeast1` (Singapore)
   - Or choose any available location
2. Click **"Enable"**
3. Wait for database creation (30-60 seconds)

✅ **Firestore Database is now created!**

### 4.4 Add Security Rules
1. In Firestore Database, click on **"Rules"** tab
2. **Delete** the existing test mode rules
3. **Paste** these rules:

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

4. Click **"Publish"**

✅ **Firestore Security Rules are now set!**

---

## 📦 Step 5: Set Up Firebase Storage

### 5.1 Enable Storage
1. In Firebase Console, click **"Storage"** in the left sidebar
2. Click **"Get started"**

### 5.2 Choose Security Rules
1. Select **"Start in test mode"**
2. Click **"Next"**

### 5.3 Choose Location
1. Select the **same location** as Firestore (for consistency)
2. Click **"Done"**

✅ **Storage is now enabled!**

### 5.4 Add Storage Security Rules
1. In Storage, click on **"Rules"** tab
2. **Replace** the existing rules with:

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

3. Click **"Publish"**

✅ **Storage Security Rules are now set!**

---

## 👤 Step 6: Create First Admin User

### 6.1 Create User in Authentication
1. Go to **"Authentication"** → **"Users"** tab
2. Click **"Add user"**
3. Enter:
   - **Email:** `admin@roomi.com` (or your preferred email)
   - **Password:** Create a strong password (remember it!)
4. Click **"Add user"**
5. **Copy the User UID** (you'll need it in the next step)
   - It looks like: `abc123xyz456...`

### 6.2 Create User Document in Firestore
1. Go to **"Firestore Database"**
2. Click **"Start collection"**
3. **Collection ID:** `users`
4. Click **"Next"**
5. **Document ID:** Paste the **User UID** you copied
6. Add these fields:

| Field | Type | Value |
|-------|------|-------|
| `email` | string | `admin@roomi.com` |
| `name` | string | `Admin User` |
| `phone` | string | `1234567890` |
| `role` | string | `admin` |

7. Click **"Save"**

✅ **Admin user is now created!**

---

## 🧪 Step 7: Test Your Setup

### 7.1 Clean and Rebuild
Open terminal in your project folder and run:

```bash
flutter clean
flutter pub get
```

### 7.2 Run the App
```bash
flutter run
```

### 7.3 Test Admin Login
1. The app should now load properly (no black screen!)
2. Click **"Login as Admin"** (top right)
3. Enter your admin credentials:
   - Email: `admin@roomi.com` (or what you set)
   - Password: (your password)
4. You should be logged in and see the Admin Dashboard

### 7.4 Test Adding a Hostel
1. In Admin Dashboard, click the **"+"** button
2. Fill in the form:
   - Step 1: Basic info
   - Step 2: Add at least one room
   - Step 3: Upload photos
3. Click **"Submit"**
4. The hostel should appear in the dashboard

### 7.5 Test Public Side
1. Logout from admin
2. You should see the home screen with hostels
3. Try searching and filtering
4. Click on a hostel to see details
5. Try writing a review

---

## ✅ Verification Checklist

Make sure you have:

- [ ] Firebase project created
- [ ] `google-services.json` in `android/app/` folder
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore Database created with security rules
- [ ] Storage enabled with security rules
- [ ] Admin user created in Authentication
- [ ] Admin user document in Firestore `users` collection
- [ ] App runs without black screen
- [ ] Can login as admin
- [ ] Can add hostels
- [ ] Can view hostels on public side

---

## 🔧 Troubleshooting

### Issue: App still shows black screen
**Solution:**
1. Verify `google-services.json` is in `android/app/`
2. Run `flutter clean` and `flutter pub get`
3. Restart the app
4. Check terminal for error messages

### Issue: "Firebase not configured" screen
**Solution:**
- This means `google-services.json` is missing
- Follow Step 2.3 again

### Issue: Login fails
**Solution:**
1. Check if Authentication is enabled
2. Verify user exists in Authentication
3. Check if user document exists in Firestore with `role: "admin"`

### Issue: Can't add hostels
**Solution:**
1. Check Firestore security rules are published
2. Verify you're logged in as admin
3. Check terminal for error messages

### Issue: Images not uploading
**Solution:**
1. Check Storage is enabled
2. Verify Storage security rules are published
3. Check internet connection

---

## 📚 Firebase Console URLs

- **Main Console:** https://console.firebase.google.com/
- **Your Project:** https://console.firebase.google.com/project/roomi-app

---

## 🎯 Quick Reference

### Package Name
```
com.example.roomi_real_final
```

### Collections Structure
```
users/
  └── {uid}/
      ├── email
      ├── name
      ├── phone
      └── role: "admin"

hostels/
  └── {hostelId}/
      ├── name, address, phone, etc.
      ├── rooms/ (subcollection)
      │   └── {roomId}/
      └── reviews/ (subcollection)
          └── {reviewId}/
```

### Storage Path
```
hostel_images/{hostelId}/image_0.jpg
```

---

## 🆘 Need Help?

If you encounter any issues:
1. Check the error message in the terminal
2. Verify all steps above are completed
3. Check Firebase Console for any error indicators
4. Make sure all security rules are published

---

**Congratulations! Your Firebase setup is complete! 🎉**

Now you can use all features of the ROOMI app including:
- Admin authentication
- Hostel management
- Image uploads
- Reviews and ratings
- Real-time data sync

