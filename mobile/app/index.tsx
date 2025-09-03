import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { onAuthStateChanged, signOut, User } from 'firebase/auth';
import { useTranslation } from 'react-i18next';
import { auth } from '../src/lib/firebase';

export default function HomePage() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const { t } = useTranslation();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
      
      if (!user) {
        // Redirect to sign-in if not authenticated
        router.replace('/(auth)/sign-in');
      }
    });

    return unsubscribe;
  }, [router]);

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      router.replace('/(auth)/sign-in');
    } catch (error) {
      Alert.alert(t('error'), 'Failed to sign out');
    }
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>{t('loading')}</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (!user) {
    return null; // Will redirect to sign-in
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>{t('welcome')}</Text>
        <Text style={styles.subtitle}>{t('homeTitle')}</Text>
        
        <View style={styles.userInfo}>
          <Text style={styles.userEmail}>
            {user.email}
          </Text>
        </View>

        <TouchableOpacity
          style={styles.signOutButton}
          onPress={handleSignOut}
        >
          <Text style={styles.signOutButtonText}>{t('signOut')}</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontSize: 16,
    color: '#666',
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
    marginBottom: 40,
    textAlign: 'center',
  },
  userInfo: {
    backgroundColor: '#f5f5f5',
    padding: 15,
    borderRadius: 8,
    marginBottom: 30,
  },
  userEmail: {
    fontSize: 16,
    color: '#333',
  },
  signOutButton: {
    backgroundColor: '#ff4757',
    paddingHorizontal: 30,
    paddingVertical: 12,
    borderRadius: 8,
  },
  signOutButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});