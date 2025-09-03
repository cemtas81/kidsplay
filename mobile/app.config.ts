import { ConfigContext, ExpoConfig } from 'expo/config';

// Simple environment variable loader
function loadEnv() {
  try {
    const fs = require('fs');
    const path = require('path');
    const envFile = path.join(__dirname, '.env');
    
    if (fs.existsSync(envFile)) {
      const content = fs.readFileSync(envFile, 'utf8');
      const env: { [key: string]: string } = {};
      
      content.split('\n').forEach((line: string) => {
        const [key, ...valueParts] = line.split('=');
        if (key && valueParts.length > 0) {
          env[key.trim()] = valueParts.join('=').trim();
        }
      });
      
      return env;
    }
  } catch (error) {
    console.warn('Could not load .env file:', error);
  }
  
  return {};
}

const env = loadEnv();

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'KidsPlay Mobile',
  slug: 'kidsplay-mobile',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  splash: {
    image: './assets/splash.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff'
  },
  assetBundlePatterns: ['**/*'],
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.kidsplay.mobile'
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#ffffff'
    },
    package: 'com.kidsplay.mobile'
  },
  web: {
    favicon: './assets/favicon.png'
  },
  extra: {
    firebase: {
      apiKey: env.FIREBASE_API_KEY || 'placeholder-api-key',
      authDomain: env.FIREBASE_AUTH_DOMAIN || 'placeholder.firebaseapp.com',
      projectId: env.FIREBASE_PROJECT_ID || 'placeholder-project',
      storageBucket: env.FIREBASE_STORAGE_BUCKET || 'placeholder.appspot.com',
      messagingSenderId: env.FIREBASE_MESSAGING_SENDER_ID || '123456789',
      appId: env.FIREBASE_APP_ID || '1:123456789:web:placeholder',
    },
    eas: {
      projectId: env.EAS_PROJECT_ID || 'placeholder-eas-id'
    }
  },
  scheme: 'kidsplay-mobile',
  plugins: [
    'expo-router'
  ]
});