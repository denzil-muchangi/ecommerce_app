# Firebase Setup Guide

This guide will help you set up Firebase for the E-Commerce Flutter app, which uses Firebase Authentication and Firestore for user management, product data, orders, and favorites.

## Prerequisites

- A Google account
- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "ecommerce-app")
4. Choose whether to enable Google Analytics (recommended for production)
5. Select your Google Analytics account or create a new one
6. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project console, click "Authentication" in the left sidebar
2. Go to the "Sign-in method" tab
3. Click "Email/Password" from the provider list
4. Toggle the "Enable" switch
5. Click "Save"

## Step 3: Enable Firestore

1. Click "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development (you can change security rules later)
4. Select a location for your database (choose the one closest to your users)
5. Click "Done"

## Step 4: Add Your Apps to Firebase

### Android App
1. Click the Android icon in the project overview
2. Enter your Android package name (found in `android/app/build.gradle` under `applicationId`)
3. Enter an optional app nickname
4. Click "Register app"
5. Download `google-services.json`
6. Place the file in `android/app/`
7. Skip the remaining steps (we'll use FlutterFire CLI)

### iOS App
1. Click the iOS icon in the project overview
2. Enter your iOS bundle ID (found in `ios/Runner.xcodeproj/project.pbxproj` or `ios/Runner/Info.plist`)
3. Enter an optional app nickname
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Place the file in `ios/Runner/`
7. Skip the remaining steps

### Web App
1. Click the Web icon in the project overview
2. Enter an app nickname
3. Check "Also set up Firebase Hosting" if you plan to deploy
4. Click "Register app"
5. Copy the config object (we'll use it later)

## Step 5: Configure FlutterFire

1. Run the following command in your project root:
   ```bash
   flutterfire configure
   ```
2. Select your Firebase project from the list
3. Select the platforms you want to configure (Android, iOS, Web)
4. This will generate/update `lib/firebase_options.dart`

## Step 6: Set Up Firestore Security Rules

In the Firebase Console, go to Firestore Database > Rules and update them for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Products are readable by all authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Categories are readable by all
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Orders are private to the user
    match /orders/{orderId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Favorites are private to the user
    match /favorites/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7: Initialize Firebase in Your App

The app already initializes Firebase in `lib/main.dart`. Make sure `Firebase.initializeApp()` is called before running the app.

## Step 8: Test the Setup

1. Run the app on your device/emulator
2. Try registering a new user
3. Check Firebase Console > Authentication to see if the user was created
4. Add some test data to Firestore and verify it appears in the app