import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import Constants from 'expo-constants';

// Get Firebase config from Expo config extra
const firebaseConfig = Constants.expoConfig?.extra?.firebase;

if (!firebaseConfig) {
  throw new Error(
    'Firebase configuration not found. Please ensure your .env file is properly configured and referenced in app.config.ts'
  );
}

// Validate required Firebase config fields
const requiredFields = ['apiKey', 'authDomain', 'projectId', 'storageBucket', 'messagingSenderId', 'appId'];
const missingFields = requiredFields.filter(field => !firebaseConfig[field]);

if (missingFields.length > 0) {
  throw new Error(
    `Missing Firebase configuration fields: ${missingFields.join(', ')}. Please check your .env file.`
  );
}

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);

export default app;