# Mobile App Setup Guide

This guide explains how to set up and run the KidsPlay mobile app built with Expo (Managed) React Native.

## Prerequisites

- Node.js 18+ and npm
- Expo CLI: `npm install -g @expo/cli`
- Android Studio (for Android development) or Xcode (for iOS development)
- A Firebase project configured for web/mobile

## Quick Start

1. **Navigate to mobile directory**
   ```bash
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and replace placeholder values with your actual Firebase configuration:
   ```env
   FIREBASE_API_KEY=your_actual_api_key
   FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
   FIREBASE_PROJECT_ID=your_actual_project_id
   FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
   FIREBASE_MESSAGING_SENDER_ID=your_actual_sender_id
   FIREBASE_APP_ID=your_actual_app_id
   ```

4. **Start the development server**
   ```bash
   npx expo start
   ```

5. **Run on device/simulator**
   - Scan the QR code with Expo Go app (iOS/Android)
   - Press `a` for Android emulator
   - Press `i` for iOS simulator (macOS only)

## Firebase Configuration

### Getting Firebase Configuration Values

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to Project Settings (⚙️ icon)
4. Scroll down to "Your apps" section
5. Click "Add app" and select "Web" (🌐)
6. Register your app with name "KidsPlay Mobile"
7. Copy the configuration values to your `.env` file

### Firebase Services Used

- **Authentication**: Email/password sign up and sign in
- **Firestore**: Database for app data (configured but not used in this scaffold)

## App Structure

```
mobile/
├── app/                    # Expo Router app directory
│   ├── _layout.tsx        # Root layout with SafeAreaProvider and i18n
│   ├── index.tsx          # Home screen (requires authentication)
│   └── (auth)/            # Authentication group
│       ├── sign-in.tsx    # Sign in screen
│       └── sign-up.tsx    # Sign up screen
├── src/
│   ├── lib/
│   │   └── firebase.ts    # Firebase initialization and config
│   └── i18n/
│       └── index.ts       # Internationalization setup
├── app.config.ts          # Expo configuration with env variables
├── .env.example           # Environment variables template
└── package.json           # Dependencies and scripts
```

## Features

### Authentication
- Email/password sign up and sign in using Firebase Auth
- Form validation with user-friendly error messages
- Automatic navigation between auth and main app screens
- Sign out functionality

### Internationalization
- Support for 5 languages: English (EN), Turkish (TR), French (FR), Arabic (AR), Russian (RU)
- Automatic device language detection
- RTL (Right-to-Left) support for Arabic
- Sample translations for auth and common UI elements

### Navigation
- Expo Router for file-based routing
- Authentication-based navigation flow
- Safe area handling for different device types

## Development

### Available Scripts

- `npm start` - Start Expo development server
- `npm run android` - Start on Android emulator/device
- `npm run ios` - Start on iOS simulator/device (macOS only)
- `npm run web` - Start web version

### Building for Production

```bash
# Install EAS CLI
npm install -g eas-cli

# Build for Android
eas build --platform android

# Build for iOS (requires Apple Developer account)
eas build --platform ios
```

## Data Management

This mobile app is designed to work independently and does not have runtime dependencies on the Flutter app's asset files. For Firebase data seeding and maintenance, refer to the [Firebase Data Maintenance Guide](FIREBASE_DATA_MAINTENANCE.md).

### Seeding Firebase Data

If you need to populate your Firebase project with initial data:

1. **Navigate to firestore utils**
   ```bash
   cd ../tools/firestore-utils
   ```

2. **Install dependencies**
   ```bash
   npm ci
   ```

3. **Set up service account credentials**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
   export GCLOUD_PROJECT="your-project-id"
   ```

4. **Seed data from repo assets**
   ```bash
   npm run seed
   ```

This will populate your Firestore with tools, hobbies, and skills data from the repository's asset files.

## Troubleshooting

### Common Issues

1. **"Firebase configuration not found" error**
   - Ensure `.env` file exists and contains all required Firebase config values
   - Verify values are not wrapped in quotes and have no extra spaces

2. **Metro bundler cache issues**
   ```bash
   npx expo start --clear
   ```

3. **Authentication errors**
   - Check Firebase project has Authentication enabled
   - Verify Email/Password provider is enabled in Firebase Console
   - Ensure your domain is added to authorized domains in Firebase Auth settings

4. **Build failures**
   - Clear node modules and reinstall: `rm -rf node_modules && npm install`
   - Clear Expo cache: `npx expo start --clear`

5. **RTL layout issues (Arabic)**
   - RTL is automatically enabled for Arabic language
   - If layout appears incorrect, restart the app after language change

### Development Tips

- Use Expo Go app for faster development iteration
- Enable hot reloading for instant code changes
- Check Expo DevTools for debugging information
- Use React Native Debugger for advanced debugging

## Next Steps

This scaffold provides a solid foundation for the KidsPlay mobile app. Potential enhancements include:

- Email verification flow (optional, requires project-side setup)
- Password reset functionality
- Biometric authentication
- Push notifications
- Offline data synchronization
- Additional screens and navigation flows
- Integration with device camera and media
- Child profile management
- Activity tracking and recommendations

## Support

For issues related to:
- **Expo/React Native**: Check [Expo Documentation](https://docs.expo.dev/)
- **Firebase**: Check [Firebase Documentation](https://firebase.google.com/docs)
- **Project-specific issues**: Refer to repository documentation and existing Flutter implementation patterns