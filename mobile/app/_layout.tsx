import { useEffect } from 'react';
import { Slot } from 'expo-router';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import '../src/i18n';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <Slot />
    </SafeAreaProvider>
  );
}