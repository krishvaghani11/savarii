# Savarii AI Agent Guidelines

## Architecture Overview
- **Framework**: Flutter with GetX for state management and routing
- **Structure**: Feature-based architecture under `lib/features/` (auth, customer, splash, vender)
- **Backend**: Firebase (Auth, Firestore, Storage) + Node.js microservice for OTP (Twilio)
- **Payments**: Razorpay integration
- **Localization**: EasyLocalization with English, Gujarati, Hindi support

## Core Patterns

### GetX Implementation
- **Controllers**: Use `.obs` for reactive variables (e.g., `var isLoading = false.obs`)
- **Bindings**: Each route has a binding file using `Get.lazyPut<Controller>(() => Controller())`
- **Permanent Services**: Core services like `AuthController` and `FirestoreService` are registered as permanent in `main.dart`
- **Navigation**: Routes defined in `app_routes.dart`, pages in `app_pages.dart` with transitions (fadeIn, rightToLeft)

### Data Flow
- **Models**: Located in `lib/models/` with Firestore integration (fromMap/toMap methods)
- **Services**: Centralized in `lib/core/services/` (FirestoreService extends GetxService)
- **Firebase Collections**: `users`, `travels` (see FirestoreService for CRUD operations)
- **Storage**: Firebase Storage for images (e.g., travels_images/)

### Feature Structure
Each feature follows:
```
features/feature_name/
├── bindings/
├── controllers/
└── view/
```

### Localization
- Keys structured as `"section": {"key": "value"}` in `assets/translations/*.json`
- Access via `.tr` extension (e.g., `'home.welcome_back'.tr`)

### Assets
- Images: `assets/images/`
- Translations: `assets/translations/` (en.json, gu.json, hi.json)

## Development Workflows

### Build Commands
- **Dependencies**: `flutter pub get`
- **Run**: `flutter run`
- **Build APK**: `flutter build apk --release`
- **Build iOS**: `flutter build ios --release`
- **Analyze**: `flutter analyze`
- **Test**: `flutter test`

### Backend (OTP Service)
- **Install**: `cd android/savarii-backend && npm install`
- **Run**: `node api/send-otp.js` or `node api/verify-otp.js`

### Firebase Configuration
- Project ID: `savarii-96869`
- Services: Auth, Firestore, Storage, App Check
- Options: `lib/firebase_options.dart`

### Key Files
- `lib/main.dart`: App initialization, service registration, localization setup
- `lib/routes/app_routes.dart`: Route constants
- `lib/routes/app_pages.dart`: Route definitions with bindings
- `lib/core/services/firestore_service.dart`: Data operations
- `pubspec.yaml`: Dependencies and assets
- `firebase.json`: Firebase project config

## Conventions
- **Imports**: Relative paths within lib (e.g., `../../../core/services/`)
- **Error Handling**: Print statements in services (e.g., `print('Error: $e')`)
- **Transitions**: Default `Transition.fadeIn`, auth flows use `Transition.rightToLeft`
- **Roles**: User roles ('customer' or 'vendor') stored in Firestore users collection
- **PDF Generation**: TicketPdfService for generating booking confirmations</content>
<parameter name="filePath">C:\Users\HP\AndroidStudioProjects\Savarii\AGENTS.md
