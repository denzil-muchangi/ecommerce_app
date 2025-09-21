# 🚀 Firebase Setup Guide for E-Commerce Flutter App

This guide walks you through setting up Firebase for your Flutter e-commerce app. No prior Firebase experience needed!

## 📋 What You'll Need

- ✅ Google account (Gmail)
- ✅ Flutter installed on your computer
- ✅ Node.js installed (for Firebase CLI)

## 🛠️ Installation (Do This First)

### Step 1: Install Firebase CLI
Open your terminal/command prompt and run:
```bash
npm install -g firebase-tools
```

### Step 2: Install FlutterFire CLI
In the same terminal, run:
```bash
dart pub global activate flutterfire_cli
```

### Step 3: Login to Firebase
```bash
firebase login
```
A browser window will open - sign in with your Google account.

---

## 📱 Step 1: Create Firebase Project

1. **Open Firebase Console**: Go to https://console.firebase.google.com/
2. **Create Project**: Click the "Create a project" button
3. **Name Your Project**:
   - Project name: `ecommerce-app` (or any name you prefer)
   - Click "Continue"
4. **Google Analytics**: Choose "Enable Google Analytics" (recommended)
5. **Analytics Setup**: Select "Default Account for Firebase" or create new
6. **Create**: Click "Create project" and wait for setup to complete

---

## 🔐 Step 2: Enable Authentication

1. **Find Authentication**: In your Firebase project, click "Authentication" in the left menu
2. **Sign-in Methods**: Click the "Sign-in method" tab
3. **Enable Email/Password**:
   - Find "Email/Password" in the list
   - Click on it
   - Toggle the "Enable" switch to ON
   - Click "Save"

---

## 🗄️ Step 3: Enable Firestore Database

1. **Find Firestore**: Click "Firestore Database" in the left menu
2. **Create Database**: Click "Create database" button
3. **Security Rules**: Choose "Start in test mode" (we'll secure it later)
4. **Database Location**: Select a location close to your users (e.g., "us-central1")
5. **Done**: Click "Done" to create the database

---

## 📱 Step 4: Add Your Apps to Firebase

### Android Setup
1. **Add Android App**: In Firebase Console, click the Android icon (🤖)
2. **Package Name**: Find this in your Flutter project:
   - Open file: `android/app/build.gradle`
   - Look for: `applicationId "com.example.ecommerce_app"`
   - Copy that value (without quotes)
3. **App Nickname**: Type "E-Commerce Android App" (optional)
4. **Register**: Click "Register app"
5. **Download Config**: Click "Download google-services.json"
6. **Place File**: Put the downloaded file in your Flutter project at: `android/app/google-services.json`
7. **Skip Steps**: Click "Next" to skip the remaining steps (we'll do this automatically)

### iOS Setup (Optional - skip if not building for iOS)
1. **Add iOS App**: Click the iOS icon (🍎)
2. **Bundle ID**: Find this in your Flutter project:
   - Open file: `ios/Runner.xcodeproj/project.pbxproj`
   - Search for: `PRODUCT_BUNDLE_IDENTIFIER`
   - Or check: `ios/Runner/Info.plist` for CFBundleIdentifier
3. **App Nickname**: Type "E-Commerce iOS App"
4. **Register**: Click "Register app"
5. **Download Config**: Download `GoogleService-Info.plist`
6. **Place File**: Put it in: `ios/Runner/GoogleService-Info.plist`
7. **Skip Steps**: Click through the remaining steps

### Web Setup
1. **Add Web App**: Click the Web icon (🌐)
2. **App Nickname**: Type "E-Commerce Web App"
3. **Firebase Hosting**: Check "Also set up Firebase Hosting" if you want web hosting
4. **Register**: Click "Register app"
5. **Copy Config**: Copy the config object shown (we'll use it later)

---

## ⚙️ Step 5: Connect Flutter to Firebase

1. **Open Terminal**: Navigate to your Flutter project root directory
2. **Run Configuration**:
   ```bash
   flutterfire configure
   ```
3. **Select Project**: Choose your Firebase project from the list
4. **Select Platforms**: Choose Android, iOS, and/or Web
5. **Confirm**: Press Enter to confirm

This creates: `lib/firebase_options.dart` (don't edit this file manually!)

---

## 🔒 Step 6: Secure Your Database (IMPORTANT!)

1. **Open Firestore Rules**: In Firebase Console, go to Firestore Database → Rules
2. **Replace All Rules**: Delete everything and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Products: anyone can read, only admins can write
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Categories: anyone can read, only admins can write
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Orders: users can only access their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Favorites: users can only access their own favorites
    match /favorites/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. **Publish Rules**: Click "Publish"

---

## 🧪 Step 7: Test Your Setup

1. **Run Your App**:
   ```bash
   flutter run
   ```

2. **Test Authentication**:
   - Try creating a new account
   - Check Firebase Console → Authentication → Users to see if it appears

3. **Test Firestore**:
   - Add some test products manually in Firebase Console
   - Check if they appear in your app

---

## 🚨 Troubleshooting

### "Firebase not initialized" Error
- Make sure `lib/firebase_options.dart` exists
- Check that `Firebase.initializeApp()` is called in `lib/main.dart`

### Authentication Not Working
- Verify Email/Password is enabled in Firebase Console
- Check your internet connection

### Firestore Permission Denied
- Make sure you're logged in to Firebase Auth
- Check that your security rules are correct

### FlutterFire Configure Fails
- Make sure Firebase CLI is installed: `firebase --version`
- Try logging out and back in: `firebase logout` then `firebase login`

---

## 🔐 Security Best Practices

1. **Never commit secrets**: Add `lib/firebase_options.dart` to `.gitignore`
2. **Use security rules**: Always implement proper Firestore security rules
3. **Validate data**: Add validation in your Flutter app before saving to Firestore
4. **Monitor usage**: Check Firebase Console regularly for unusual activity

---

## 📚 Next Steps

After Firebase is set up, continue with:
- [Paystack Setup Guide](PAYSTACK_README.md)
- [Webhook Setup Guide](WEBHOOK_SETUP_README.md)

Your Firebase setup is now complete! 🎉