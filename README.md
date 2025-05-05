# **🚗 CarRental App**

A Flutter-based mobile application for managing personal car listings and rentals using Firebase as the backend.

## 📱 Features

- 🔐 **User Authentication**: Secure sign-in using Firebase Authentication.
  
- 🚘 **Add & Manage Cars**: Logged-in users can add, view, and delete their own car listings.
  
- 📷 **Car Image Display**: Upload and display car images from Firebase.
  
- 👤 **Rental Status**: View who rented the car (name, email) and until when.
  
- 🔄 **Real-Time Updates**: Uses Firestore Streams to display up-to-date listings instantly.
  
- 🗑️ **Delete Listings**: Instantly delete car entries from the app.
  
- 🧠 **Robust Error Handling**: Handles missing fields and type mismatches gracefully (e.g., Timestamp vs String).

## 🛠️ Tech Stack

- **Flutter**: UI Framework
  
- **Dart**: Programming Language
  
- **Firebase Authentication**: User login management
  
- **Cloud Firestore**: Real-time database
  
- **Firebase Storage** *(optional)*: For hosting car images

## 📦 Setup Instructions

1. **Clone this repository**
   
   ```bash

   git clone https://github.com/your-username/mycarrental-app.git

   cd mycarrental-app

2. **Install dependencies**
   
   flutter pub get

3. **Set up Firebase**

   Create a Firebase project at Firebase Console

   Enable Email/Password Authentication

   Create a Cloud Firestore database

   Download google-services.json and place it in your /android/app/ folder

4. **Run the app**

   flutter run

  
