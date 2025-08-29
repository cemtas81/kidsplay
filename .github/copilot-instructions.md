# KidsPlay Flutter App - Development Instructions

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Setup
- **CRITICAL**: Install Flutter SDK first:
  - Option 1: `snap install flutter --classic` (if snap is available)
  - Option 2: Download from https://docs.flutter.dev/get-started/install/linux and extract to `/opt/flutter`, then add to PATH
  - Option 3: If network restrictions exist: Document "Flutter installation blocked by firewall/network restrictions"
  - **KNOWN ISSUE**: Flutter installation may fail due to corrupted Dart SDK downloads. If this occurs, try multiple times or document the failure.
- Verify installation: `flutter --version` (should show Flutter 3.24+ and Dart 3.4+)
- **CRITICAL**: Run `flutter doctor` first to check dependencies - NEVER CANCEL, can take 5-10 minutes. Set timeout to 15+ minutes.
- **DEPENDENCY INSTALLATION**: `cd kidsplay && flutter pub get` - takes 2-3 minutes for 67 Dart files. NEVER CANCEL. Set timeout to 10+ minutes.
- **NOTE**: Project requires Flutter SDK ^3.6.0 (README incorrectly states ^3.29.2)
- **Java requirement**: Ensure Java 17+ is installed for Android builds (`java --version`)

### Build Process
- **CRITICAL BUILD COMMAND**: `flutter build apk --debug` - takes 15-25 minutes on first build (67 Dart files + dependencies). NEVER CANCEL. Set timeout to 40+ minutes.
- Subsequent builds: `flutter build apk --debug` - takes 5-15 minutes. NEVER CANCEL. Set timeout to 25+ minutes.
- **RELEASE BUILD**: `flutter build apk --release` - takes 20-30 minutes. NEVER CANCEL. Set timeout to 45+ minutes.
- **iOS BUILD** (if on macOS): `flutter build ios --release` - takes 25-35 minutes. NEVER CANCEL. Set timeout to 50+ minutes.
- **CLEAN BUILD**: If issues occur, run `flutter clean && flutter pub get` then retry build - adds 5+ minutes

### Run and Test
- **DEVELOPMENT RUN**: `flutter run` - takes 3-5 minutes to start. NEVER CANCEL. Set timeout to 10+ minutes.
- **HOT RELOAD**: Press `r` in terminal after flutter run starts for instant reloads
- **HOT RESTART**: Press `R` in terminal for full app restart 
- **STOP**: Press `q` in terminal to stop the development server

### Linting and Code Quality
- **LINT CHECK**: `flutter analyze` - takes 1-3 minutes for 67 Dart files. NEVER CANCEL. Set timeout to 10+ minutes.
- **FORMAT CODE**: `dart format lib/` - runs instantly for all Dart files
- **CRITICAL**: Always run `flutter analyze && dart format lib/` before committing changes
- **LINT RULES**: Project uses flutter_lints ^5.0.0 for code quality enforcement

## Validation

### Manual Validation Scenarios
After making any changes, ALWAYS run through these complete user scenarios:

1. **Complete App Flow**:
   - Start app with `flutter run`
   - Navigate: Splash → Parent Login → Child Selection Dashboard
   - Tap on a child card to enter Child Activity Screen
   - Tap "Start Activity" to open Activity Detail Screen
   - Test camera functionality (if available)
   - Navigate back to dashboard and test "View Progress" 
   - Test Settings tab → Multi-Parent Management and Subscription screens

2. **Navigation Testing**:
   - Test all bottom navigation tabs
   - Test all button interactions
   - Verify screen transitions are smooth
   - Check that back navigation works correctly

3. **Firebase Integration**:
   - App should start without Firebase errors
   - Check logs for Firebase initialization success

### Key Functional Areas to Always Test
- **Activity Recommendation Engine** (`lib/core/activity_recommendation_engine.dart`)
- **Child Profile Management** (Child Profile Creation and Selection)
- **Multi-Parent Features** (Parent invitation system)
- **Progress Tracking** (Charts and achievements display)
- **Firebase Authentication** (if implemented)

## Common Tasks

### Project Structure Overview
```
kidsplay/
├── android/                 # Android build configuration
├── ios/                     # iOS build configuration  
├── lib/
│   ├── core/               # Core utilities and recommendation engine
│   ├── data/               # Data repositories and content loading
│   ├── models/             # Data models (Activity, Child, etc.)
│   ├── presentation/       # All screen implementations
│   │   ├── splash_screen/
│   │   ├── parent_login/
│   │   ├── child_profile_creation/
│   │   ├── child_selection_dashboard/
│   │   ├── child_activity/
│   │   ├── activity_detail/
│   │   ├── progress_tracking/
│   │   ├── multi_parent_management/
│   │   └── subscription/
│   ├── routes/             # App navigation routes
│   ├── theme/              # UI theming and styles
│   └── widgets/            # Reusable UI components
├── assets/
│   ├── data/               # JSON data files for activities/tools
│   └── images/             # App images and icons
└── pubspec.yaml            # Dependencies and configuration
```

### Important Navigation Routes
All routes defined in `lib/routes/app_routes.dart`:
- `/` - Splash Screen (initial route)
- `/parent-login` - Parent authentication  
- `/child-profile-creation` - Create new child profiles
- `/child-selection-dashboard` - Main dashboard with child cards
- `/multi-parent-management` - Parent sharing and permissions

### Key Dependencies (DO NOT REMOVE marked ones)
- **sizer: ^2.0.15** - Required for responsive design (DO NOT REMOVE)
- **firebase_core: ^4.0.0** - Firebase integration (DO NOT REMOVE) 
- **firebase_auth: ^6.0.1** - Authentication (DO NOT REMOVE)
- **cloud_firestore: ^6.0.0** - Database (DO NOT REMOVE)
- **camera: ^0.10.5+5** - Activity photo capture
- **fl_chart: ^0.65.0** - Progress tracking charts
- **shared_preferences: ^2.2.2** - Local storage (DO NOT REMOVE)
- **flutter_svg: ^2.0.9** - SVG support (DO NOT REMOVE)
- **google_fonts: ^6.1.0** - Typography (DO NOT REMOVE)
- **flutter_lints: ^5.0.0** - Code quality (DO NOT REMOVE)

### Firebase Configuration
- Project uses Firebase project ID: `kidsplay-8132`
- Firebase options configured in `lib/firebase_options.dart`
- **CRITICAL**: App requires Firebase initialization in main.dart (DO NOT REMOVE Firebase.initializeApp())

## Build Configuration

### Android Specific
- **Minimum SDK**: 23 (Android 6.0)
- **Target SDK**: Uses Flutter default
- **Multidex**: Enabled (required for Firebase)
- **Package**: com.kidsplay.app

### iOS Specific  
- **Bundle ID**: com.kidsplay.app.testProject
- **iOS Target**: Uses Flutter default (iOS 9.0+)

## Content and Data

### Mock Data Location
- **Activities**: `assets/data/activities.json` and `assets/data/activity.json` (fallback)
- **Tools**: `assets/data/tools.json` 
- **Skills**: `assets/data/skills.json`
- **Hobbies**: `assets/data/hobbies.json`

### Content Repository
- All data loading handled by `lib/data/content_repository.dart`
- Includes fallback mechanisms for missing JSON files
- **CRITICAL**: Always test that ContentRepository.init() completes successfully
- **Sample Activity Structure**: Activities include multi-language support (TR, EN, FR, AR, RU, DE, ES)
- **Activity Features**: Age ranges (1.5-3+), duration tracking, parent involvement flags, camera requirements

## Troubleshooting

### Common Issues
- **Firebase initialization fails**: Check `google-services.json` in `android/app/` directory exists and is valid
- **Build failures**: Run `flutter clean && flutter pub get` then retry build
- **Hot reload not working**: Stop and restart with `flutter run`
- **Import errors**: Check `lib/core/app_export.dart` for common exports
- **Flutter installation corrupted**: Dart SDK download may fail - retry installation or try different download method
- **Network restrictions**: If snap/downloads fail, document "Installation blocked by firewall restrictions"

### Installation Fallback Process
If Flutter installation fails repeatedly:
1. Document the specific error (corrupted zip, network timeout, etc.)
2. Note which installation method was attempted
3. Recommend user install Flutter manually outside of sandboxed environment
4. Still provide all other instructions for when Flutter is available

### Performance Notes
- **Project Size**: 67 Dart files across 12+ screens
- **First build always takes 15-25 minutes** due to dependency downloads and compilation
- **Cold start takes 3-5 minutes** for development mode
- **Release builds take 20-30 minutes** but are required for performance testing
- **Hot reload works instantly** once development server is running
- **Dependencies**: 15+ packages including Firebase, camera, charts requiring native compilation

### Error Patterns to Watch For
- Firebase configuration errors in logs
- Camera permission issues on device testing
- Memory issues with chart rendering (fl_chart)
- Network connectivity issues (connectivity_plus dependency)

## Critical Reminders
- **NEVER CANCEL** any build or test command before expected completion time
- **ALWAYS TEST** complete user flows after making changes  
- **ALWAYS RUN** `flutter analyze && dart format lib/` before committing
- **Firebase is CRITICAL** - do not modify initialization code in main.dart
- **Portrait orientation only** - orientation lock is enforced in main.dart