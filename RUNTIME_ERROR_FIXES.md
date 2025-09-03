# Flutter Runtime Error Fixes - Auth Flow

## Overview
This document details the fixes implemented to resolve Flutter runtime errors during onboarding/auth flows in mock mode.

## Issues Fixed

### 1. setState() called during build
**Error**: `setState() or markNeedsBuild() called during build. Overlay-[LabeledGlobalKey`

**Root Cause**: In `splash_screen.dart`, `setState()` was being called within async operations that could execute during the widget build process.

**Fix Applied**:
```dart
// Before: Called immediately in initState
@override
void initState() {
  super.initState();
  _initializeAnimations();
  _startSplashSequence(); // ❌ Could trigger setState during build
}

// After: Deferred until after first frame
@override
void initState() {
  super.initState();
  _initializeAnimations();
  // ✅ Defer context-dependent work until after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startSplashSequence();
  });
}
```

**Additional Safety**:
- Removed setState calls from within async operations
- Added mounted checks before all setState calls
- Computed navigation target before setState

### 2. Google Sign-In attempted in mock mode
**Error**: User could tap Google Sign-In button despite mock mode being active

**Root Cause**: The social login widget didn't check for mock mode status, allowing users to attempt Google Sign-In which would fail.

**Fix Applied**:
```dart
// Added mock mode detection
import '../../../services/auth_service.dart';

// Conditionally render Google button
AuthService.isUsingMockAuth 
  ? Tooltip(
      message: 'Google Sign-In not available in demo mode.\nUse: demo@demo.com / demo1234',
      child: _SocialLoginButton(
        onTap: () => _showMockModeMessage(context),
        // ... disabled styling
        isDisabled: true,
      ),
    )
  : _SocialLoginButton(
      onTap: () => _handleSocialLogin(context, 'google'),
      // ... normal styling
    ),
```

**User Experience Improvements**:
- Google button is visually disabled in mock mode
- Tooltip explains why it's disabled
- Helpful snackbar message when tapped
- Clear guidance to use demo credentials

### 3. Navigation timing conflicts
**Error**: Navigation calls during widget disposal or build processes

**Root Cause**: Navigation methods were called without checking if the widget was still mounted.

**Fix Applied**:
```dart
// Before: No mounted checks
if (user != null && mounted) {
  // ... get children
  if (children.isNotEmpty) {
    Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/child-profile-creation');
  }
}

// After: Added additional mounted guard
if (user != null && mounted) {
  // ... get children
  if (mounted) { // ✅ Additional check before navigation
    if (children.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/child-profile-creation');
    }
  }
}
```

## Technical Details

### Lifecycle Management
1. **PostFrameCallback**: Ensures splash sequence starts after widget tree is built
2. **Mounted Checks**: All async operations verify widget is still active
3. **State Updates**: setState calls happen only after async operations complete

### Mock Mode Handling
1. **Visual Feedback**: Disabled Google button with reduced opacity
2. **User Guidance**: Tooltip and snackbar explain demo mode
3. **Error Prevention**: Prevents Google Sign-In API calls in mock mode

### Error Boundaries
1. **Try-Catch Blocks**: All async operations wrapped in error handling
2. **Graceful Degradation**: Fallback navigation on initialization errors
3. **User Feedback**: Clear error messages guide users to demo credentials

## Testing Scenarios

### With Mock Mode Enabled (`_useMockAuth = true`)
1. **Splash Screen**:
   - ✅ No setState during build errors
   - ✅ Smooth navigation to appropriate screen
   - ✅ Proper error handling if Firebase unavailable

2. **Login Screen**:
   - ✅ Email/password login works with demo credentials
   - ✅ Google button is disabled with helpful message
   - ✅ No runtime errors on navigation

3. **User Flow**:
   - ✅ demo@demo.com / demo1234 login succeeds
   - ✅ Navigation based on existing children works
   - ✅ All setState calls happen after async completion

### Demo Flow
```
1. App starts → Splash Screen
2. PostFrameCallback → Initialize app safely
3. Check auth state → Determine navigation
4. setState after async → Store target route
5. Navigate → Login or Dashboard
6. Login attempt → Mock auth validation
7. Success → Navigate to appropriate screen
```

## Benefits

### Performance
- Eliminates Flutter lifecycle violations
- Reduces unnecessary widget rebuilds
- Smoother app startup experience

### User Experience
- Clear feedback about demo mode limitations
- Helpful guidance for testing credentials
- No confusing error states

### Maintainability
- Consistent error handling patterns
- Clear separation of concerns
- Easy to extend for additional providers

## Future Considerations

1. **Testing**: Add widget tests for lifecycle edge cases
2. **Monitoring**: Log timing of initialization steps
3. **Enhancement**: Consider disabling all social buttons in mock mode
4. **Documentation**: Update user guide with demo credentials

## Dependencies Updated
- No new dependencies added
- Used existing Flutter framework features
- Leveraged AuthService's existing mock mode flag