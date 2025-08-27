import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';

class DemoDataHelper {
  static final AuthService _authService = AuthService();
  static final UserDataService _userDataService = UserDataService();

  static Future<void> createDemoData() async {
    try {
      // Create demo parent account
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: 'demo@kidsplay.com',
        password: 'Demo123!',
        fullName: 'Demo Parent',
      );

      if (userCredential?.user != null) {
        final userId = userCredential!.user!.uid;

        // Create user profile
        await _userDataService.createUserProfile(
          userId: userId,
          email: 'demo@kidsplay.com',
          fullName: 'Demo Parent',
        );

        // Create sample children
        await _createSampleChildren(userId);
      }
    } catch (e) {
      debugPrint('Demo data creation failed: $e');
    }
  }

  static Future<void> _createSampleChildren(String parentId) async {
    // Child 1: Emma
    await _userDataService.createChildProfile(
      parentId: parentId,
      name: 'Emma Rodriguez',
      age: 4,
      gender: 'girl',
      hobbies: ['Drawing', 'Dancing', 'Building blocks'],
      additionalData: {
        'todayActivities': 3,
        'dailyGoal': 5,
        'currentStreak': 7,
        'badges': [
          {'name': 'Creative', 'icon': 'palette'},
          {'name': 'Active', 'icon': 'directions_run'},
          {'name': 'Explorer', 'icon': 'explore'}
        ],
        'screenTime': '2 hours',
        'lastActivity': 'Creative Drawing',
        'completionRate': 85,
        'profileImageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?fm=jpg&q=60&w=400&ixlib=rb-4.0.3',
      },
    );

    // Child 2: Lucas
    await _userDataService.createChildProfile(
      parentId: parentId,
      name: 'Lucas Chen',
      age: 6,
      gender: 'boy',
      hobbies: ['Science experiments', 'Lego building', 'Reading'],
      additionalData: {
        'todayActivities': 5,
        'dailyGoal': 6,
        'currentStreak': 12,
        'badges': [
          {'name': 'Scientist', 'icon': 'science'},
          {'name': 'Builder', 'icon': 'construction'},
          {'name': 'Reader', 'icon': 'menu_book'}
        ],
        'screenTime': '1.5 hours',
        'lastActivity': 'Nature Explorer',
        'completionRate': 92,
        'profileImageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fm=jpg&q=60&w=400&ixlib=rb-4.0.3',
      },
    );

    // Child 3: Sophia
    await _userDataService.createChildProfile(
      parentId: parentId,
      name: 'Sophia Williams',
      age: 3,
      gender: 'girl',
      hobbies: ['Singing', 'Helping mom', 'Playing with dolls'],
      additionalData: {
        'todayActivities': 2,
        'dailyGoal': 4,
        'currentStreak': 3,
        'badges': [
          {'name': 'Musical', 'icon': 'music_note'},
          {'name': 'Helper', 'icon': 'volunteer_activism'}
        ],
        'screenTime': '1 hour',
        'lastActivity': 'Musical Time',
        'completionRate': 78,
        'profileImageUrl': 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?fm=jpg&q=60&w=400&ixlib=rb-4.0.3',
      },
    );
  }

  // For testing purposes, this method can be called to quickly create demo data
  static void showDemoDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Demo Data'),
        content: const Text(
          'Would you like to create demo data for testing?\n\n'
          'This will create:\n'
          '• Demo parent account (demo@kidsplay.com)\n'
          '• Three sample children profiles\n\n'
          'Password: Demo123!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await createDemoData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo data created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create demo data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}