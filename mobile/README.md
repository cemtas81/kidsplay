# KidsPlay Mobile App

A production-friendly React Native mobile app built with Expo (Managed workflow).

## Features

- **TypeScript** for type safety
- **Expo Router** for file-based navigation
- **Firebase Authentication** with email/password
- **Multi-language support** (TR, EN, FR, AR, RU) with RTL support
- **Responsive design** with safe area handling

## Quick Start

1. **Setup environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase configuration
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development**
   ```bash
   npx expo start
   ```

## Documentation

See [Mobile Setup Guide](../docs/MOBILE_SETUP.md) for detailed setup instructions and Firebase configuration.

## Project Structure

- `app/` - Expo Router app directory with screens
- `src/lib/firebase.ts` - Firebase initialization
- `src/i18n/` - Internationalization setup
- `app.config.ts` - Expo configuration

## Scripts

- `npm start` - Start Expo development server
- `npm run android` - Run on Android
- `npm run ios` - Run on iOS (macOS only)
- `npm run web` - Run web version