# Flutter Mobile App - Project Structure Template

> **A clean architecture template for Flutter mobile applications with offline-first capabilities, GetX state management, and best practices.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Architecture](#project-architecture)
- [Directory Structure](#directory-structure)
- [Core Principles](#core-principles)
- [Feature Implementation Guide](#feature-implementation-guide)
- [Widget Library](#widget-library)
- [State Management](#state-management)
- [Data Layer](#data-layer)
- [Navigation & Routing](#navigation--routing)
- [Best Practices Checklist](#best-practices-checklist)

---

## 🎯 Overview

This template follows **clean architecture principles** with clear separation of concerns, making it ideal for:
- Sales/Field force automation apps
- Offline-first mobile applications
- Multi-language (i18n) applications
- Apps requiring local data caching
- Apps with complex navigation flows

---

## 🛠 Tech Stack

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^5.0.0  # GetX for state management, navigation, and dependency injection
  
  # Network & API
  dio: ^5.9.0  # HTTP client
  dio_smart_retry: ^6.0.0  # Automatic retry with exponential backoff
  
  # Local Storage
  hive: ^2.2.3  # NoSQL database
  hive_flutter: ^1.1.0
  
  # Connectivity
  connectivity_plus: ^6.1.2  # Network status monitoring
  geolocator: ^13.0.2  # Location services
  
  # UI Components
  curved_navigation_bar: ^1.0.6  # Bottom navigation
  
  # Utilities
  intl: ^0.19.0  # Internationalization
  logger: ^2.5.0  # Logging

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  hive_generator: ^2.0.1  # Code generation for Hive
  build_runner: ^2.4.14
```

---

## 🏗 Project Architecture

### Architecture Pattern: MVC with GetX

```
┌─────────────────────────────────────────────────────┐
│                      VIEW LAYER                      │
│  (UI Components, Screens, Reusable Widgets)         │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                  CONTROLLER LAYER                    │
│  (Business Logic, State Management, GetX)           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                   DATA LAYER                         │
│  ┌──────────────┬──────────────┬─────────────────┐ │
│  │ Repositories │  Providers   │     Models      │ │
│  └──────────────┴──────────────┴─────────────────┘ │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                 SERVICE LAYER                        │
│  (Storage, Network, Location, Cache, etc.)          │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
lib/
├── main.dart                          # App entry point
│
├── app/
│   ├── data/                          # DATA LAYER
│   │   ├── models/                    # Data models (with Hive adapters)
│   │   │   ├── user_model.dart
│   │   │   ├── user_model.g.dart      # Generated Hive adapter
│   │   │   ├── product_model.dart
│   │   │   └── transaction_model.dart
│   │   │
│   │   ├── providers/                 # API providers (HTTP clients)
│   │   │   ├── api_provider.dart      # Main API provider with Dio
│   │   │   └── auth_provider.dart
│   │   │
│   │   └── repositories/              # Repository pattern (data abstraction)
│   │       ├── auth_repository.dart
│   │       ├── data_repository.dart
│   │       └── sync_repository.dart
│   │
│   ├── modules/                       # FEATURE MODULES
│   │   ├── auth/                      # Authentication feature
│   │   │   ├── bindings/
│   │   │   │   └── auth_binding.dart  # Dependency injection
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   └── views/
│   │   │       ├── login_view.dart
│   │   │       └── splash_view.dart
│   │   │
│   │   ├── home/                      # Home/Dashboard feature
│   │   │   ├── bindings/
│   │   │   │   ├── dashboard_binding.dart
│   │   │   │   └── list_binding.dart
│   │   │   ├── controllers/
│   │   │   │   ├── dashboard_controller.dart
│   │   │   │   └── list_controller.dart
│   │   │   └── views/
│   │   │       ├── dashboard_view.dart
│   │   │       └── list_view.dart
│   │   │
│   │   ├── settings/                  # Settings feature
│   │   │   └── controllers/
│   │   │       └── settings_controller.dart
│   │   │
│   │   └── [feature_name]/            # Additional features
│   │       ├── bindings/
│   │       ├── controllers/
│   │       └── views/
│   │
│   ├── routes/                        # NAVIGATION
│   │   ├── app_routes.dart            # Route constants
│   │   └── app_pages.dart             # Route definitions & bindings
│   │
│   ├── services/                      # CORE SERVICES
│   │   ├── cache_manager.dart         # Cache management
│   │   ├── connectivity_service.dart  # Network monitoring
│   │   ├── dependency_injection.dart  # DI setup
│   │   ├── location_service.dart      # GPS/Location
│   │   └── storage_service.dart       # Local database (Hive)
│   │
│   ├── theme/                         # THEMING
│   │   ├── app_theme.dart             # Theme definitions
│   │   ├── app_colors.dart            # Color palette
│   │   └── app_colors_extension.dart  # Theme extensions
│   │
│   ├── utils/                         # UTILITIES
│   │   ├── api_error_handler.dart     # Error handling
│   │   ├── constants.dart             # App constants
│   │   ├── logger.dart                # Logging utility
│   │   ├── rate_limit_interceptor.dart # API rate limiting
│   │   └── translations.dart          # i18n translations
│   │
│   └── widgets/                       # SHARED WIDGETS
│       ├── app_background.dart        # Background widget
│       ├── app_bottom_navigation.dart # Bottom navigation
│       ├── app_drawer.dart            # Navigation drawer
│       ├── custom_dropdown.dart       # Custom dropdown
│       ├── date_picker_field.dart     # Date picker
│       ├── empty_state_widget.dart    # Empty state display
│       ├── glassmorphic_container.dart
│       ├── invoice_card_widget.dart   # Feature-specific cards
│       └── voucher_card_widget.dart
│
├── assets/                            # ASSETS
│   ├── fonts/                         # Custom fonts
│   │   ├── Cairo-Regular.ttf
│   │   └── Cairo-Bold.ttf
│   │
│   └── images/                        # Images
│       ├── logo.png
│       ├── bg.png
│       ├── bg-light.png
│       └── icons/
│
└── test/                              # TESTS
    └── widget_test.dart
```

---

## 🎯 Core Principles

### 1. **Single Responsibility Principle (SRP)**
- Each file/class has ONE clear purpose
- Controllers handle business logic only
- Views handle UI only
- Services handle cross-cutting concerns

### 2. **Don't Repeat Yourself (DRY)**
- Extract common UI components into widgets
- Use shared services for common functionality
- Create helper functions for repeated operations

### 3. **Separation of Concerns**
```
View        → What user sees
Controller  → Business logic & state
Repository  → Data access abstraction  
Provider    → API/Network calls
Service     → Infrastructure (storage, network, etc.)
```

### 4. **Offline-First Architecture**
- Cache all essential data locally
- Sync when online
- Queue operations when offline
- Show cached data immediately

### 5. **Dependency Injection**
- Use GetX bindings for DI
- Initialize services at app start
- Lazy loading when appropriate

---

## 📖 Feature Implementation Guide

### Step 1: Create Feature Module Structure

```
modules/
└── feature_name/
    ├── bindings/
    │   └── feature_binding.dart
    ├── controllers/
    │   └── feature_controller.dart
    └── views/
        └── feature_view.dart
```

### Step 2: Define Data Model

```dart
// app/data/models/feature_model.dart
import 'package:hive/hive.dart';

part 'feature_model.g.dart';

@HiveType(typeId: 1)  // Unique ID for each model
class FeatureModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final DateTime createdAt;

  FeatureModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

Run: `flutter pub run build_runner build` to generate Hive adapters.

### Step 3: Create API Provider Methods

```dart
// app/data/providers/api_provider.dart
Future<Response> getFeatureList() async {
  return await _dio.get('/api/features/');
}

Future<Response> createFeature(Map<String, dynamic> data) async {
  return await _dio.post('/api/features/', data: data);
}
```

### Step 4: Create Repository

```dart
// app/data/repositories/feature_repository.dart
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/feature_model.dart';

class FeatureRepository {
  final ApiProvider _apiProvider = Get.find();

  Future<List<FeatureModel>> getFeatures() async {
    try {
      final response = await _apiProvider.getFeatureList();
      return (response.data as List)
          .map((e) => FeatureModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load features');
    }
  }
}
```

### Step 5: Create Controller

```dart
// app/modules/feature_name/controllers/feature_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/feature_repository.dart';
import '../../../data/models/feature_model.dart';

class FeatureController extends GetxController {
  final FeatureRepository _repository = Get.find();
  
  // Observable state
  final items = <FeatureModel>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      items.value = await _repository.getFeatures();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refresh() => loadData();
}
```

### Step 6: Create Binding

```dart
// app/modules/feature_name/bindings/feature_binding.dart
import 'package:get/get.dart';
import '../controllers/feature_controller.dart';
import '../../../data/repositories/feature_repository.dart';

class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeatureRepository());
    Get.lazyPut(() => FeatureController());
  }
}
```

### Step 7: Create View

```dart
// app/modules/feature_name/views/feature_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feature_controller.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/empty_state_widget.dart';

class FeatureView extends GetView<FeatureController> {
  const FeatureView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature')),
      drawer: AppDrawer(),
      body: AppBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (controller.items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inbox,
              message: 'No items found',
            );
          }
          
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return ListTile(title: Text(item.name));
              },
            ),
          );
        }),
      ),
    );
  }
}
```

### Step 8: Register Route

```dart
// app/routes/app_routes.dart
class AppRoutes {
  static const featureName = '/feature-name';
}

// app/routes/app_pages.dart
GetPage(
  name: AppRoutes.featureName,
  page: () => FeatureView(),
  binding: FeatureBinding(),
),
```

---

## 🎨 Widget Library

### Shared Widgets Philosophy

Create reusable widgets for:
- **Navigation components** (bottom nav, drawer, app bar)
- **Empty states** (no data, no results, errors)
- **Cards** (list items, detail cards)
- **Form fields** (date pickers, dropdowns, inputs)
- **Containers** (backgrounds, sections)

### Widget Template

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Brief description of widget purpose
/// 
/// Usage:
/// ```dart
/// WidgetName(
///   property: value,
/// )
/// ```
class WidgetName extends StatelessWidget {
  final String requiredProperty;
  final VoidCallback? onTap;
  final bool optionalFlag;

  const WidgetName({
    Key? key,
    required this.requiredProperty,
    this.onTap,
    this.optionalFlag = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(requiredProperty),
    );
  }
}
```

### Common Shared Widgets

1. **AppBottomNavigation** - Centralized bottom navigation
2. **EmptyStateWidget** - Consistent empty states
3. **LoadingWidget** - Loading indicators
4. **ErrorWidget** - Error displays
5. **CardWidget** - Reusable card components
6. **CustomDropdown** - Styled dropdowns
7. **DatePickerField** - Date selection
8. **AppBackground** - Background styling

---

## 🔄 State Management

### GetX State Management Pattern

#### 1. Reactive Variables (Preferred)

```dart
class MyController extends GetxController {
  // Observable variables
  final count = 0.obs;
  final user = Rx<User?>(null);
  final items = <Item>[].obs;
  
  // Computed values
  bool get isLoggedIn => user.value != null;
  
  // Actions
  void increment() => count.value++;
  
  void setUser(User newUser) {
    user.value = newUser;
  }
}

// In View
Obx(() => Text('Count: ${controller.count.value}'))
```

#### 2. Simple State Manager (Alternative)

```dart
class MyController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update(); // Triggers rebuild
  }
}

// In View
GetBuilder<MyController>(
  builder: (controller) => Text('Count: ${controller.count}')
)
```

### Lifecycle Hooks

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is created
    loadData();
  }
  
  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered
  }
  
  @override
  void onClose() {
    // Called when controller is destroyed
    // Clean up resources
    super.onClose();
  }
}
```

---

## 💾 Data Layer

### Local Storage with Hive

#### Setup Storage Service

```dart
// app/services/storage_service.dart
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_model.dart';

class StorageService extends GetxService {
  late Box<UserModel> _userBox;
  late Box _settingsBox;
  
  Future<StorageService> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    
    // Open boxes
    _userBox = await Hive.openBox<UserModel>('users');
    _settingsBox = await Hive.openBox('settings');
    
    return this;
  }
  
  // User operations
  Future<void> saveUser(UserModel user) async {
    await _userBox.put('current', user);
  }
  
  UserModel? getUser() => _userBox.get('current');
  
  Future<void> clearUser() async {
    await _userBox.clear();
  }
  
  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}
```

### Repository Pattern

```dart
// app/data/repositories/data_repository.dart
class DataRepository {
  final ApiProvider _apiProvider = Get.find();
  final StorageService _storage = Get.find();
  final ConnectivityService _connectivity = Get.find();
  
  Future<List<Item>> getItems({bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = _storage.getCachedItems();
      if (cached.isNotEmpty) return cached;
    }
    
    // Check connectivity
    if (!_connectivity.isConnected) {
      throw Exception('No internet connection');
    }
    
    // Fetch from API
    final response = await _apiProvider.getItems();
    final items = (response.data as List)
        .map((e) => Item.fromJson(e))
        .toList();
    
    // Cache results
    await _storage.cacheItems(items);
    
    return items;
  }
}
```

---

## 🧭 Navigation & Routing

### Route Definition

```dart
// app/routes/app_routes.dart
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
}
```

### Route Configuration

```dart
// app/routes/app_pages.dart
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
```

### Navigation Methods

```dart
// Navigate to route
Get.toNamed(AppRoutes.home);

// Navigate with arguments
Get.toNamed(AppRoutes.profile, arguments: {'userId': 123});

// Navigate and remove previous route
Get.offNamed(AppRoutes.login);

// Navigate and clear stack
Get.offAllNamed(AppRoutes.home);

// Navigate back
Get.back();

// Navigate back with result
Get.back(result: {'success': true});
```

---

## 🎨 Theming

### Theme Structure

```dart
// app/theme/app_colors.dart
class AppColors {
  // Light theme colors
  static const primaryLight = Color(0xFF6200EE);
  static const secondaryLight = Color(0xFF03DAC6);
  static const backgroundLight = Color(0xFFF5F5F5);
  
  // Dark theme colors
  static const primaryDark = Color(0xFFBB86FC);
  static const secondaryDark = Color(0xFF03DAC6);
  static const backgroundDark = Color(0xFF121212);
}

// app/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'YourFont',
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    // ... more theme properties
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'YourFont',
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    // ... more theme properties
  );
}
```

### Theme Extension

```dart
// app/theme/app_colors_extension.dart
extension AppColorsExtension on BuildContext {
  AppColorsData get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppColorsData.dark() : AppColorsData.light();
  }
}

class AppColorsData {
  final Color primary;
  final Color surface;
  final Color navBar;
  // ... more colors
  
  AppColorsData.light() : 
    primary = AppColors.primaryLight,
    surface = Colors.white,
    navBar = Colors.white;
  
  AppColorsData.dark() : 
    primary = AppColors.primaryDark,
    surface = Color(0xFF1E1E1E),
    navBar = Color(0xFF2C2C2C);
}
```

---

## 🌍 Internationalization

### Translation Setup

```dart
// app/utils/translations.dart
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'app_name': 'My App',
      'login': 'Login',
      'logout': 'Logout',
      'welcome': 'Welcome @name',
      'items_count': '@count items',
    },
    'ar': {
      'app_name': 'تطبيقي',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'welcome': 'مرحباً @name',
      'items_count': '@count عنصر',
    },
  };
}

// Usage in code
Text('login'.tr)
Text('welcome'.trParams({'name': 'John'}))
Text('items_count'.trParams({'count': '5'}))
```

---

## ✅ Best Practices Checklist

### Project Setup
- [ ] Initialize GetX dependency injection in `main.dart`
- [ ] Set up Hive with all model adapters
- [ ] Configure API provider with base URL and interceptors
- [ ] Set up connectivity service
- [ ] Initialize storage service
- [ ] Configure app theme (light/dark)
- [ ] Set up translations

### Code Organization
- [ ] Each feature has its own module folder
- [ ] Controllers only contain business logic
- [ ] Views only contain UI code
- [ ] Repositories handle data access
- [ ] Providers handle API calls
- [ ] Services are singleton and injected globally

### Widget Development
- [ ] Extract reusable UI into shared widgets
- [ ] Create card widgets for list items
- [ ] Use const constructors where possible
- [ ] Add key parameters to stateless widgets
- [ ] Document widget parameters

### State Management
- [ ] Use `.obs` for reactive variables
- [ ] Wrap UI in `Obx()` for reactivity
- [ ] Dispose controllers properly
- [ ] Use bindings for dependency injection
- [ ] Avoid business logic in views

### Data Management
- [ ] Cache all critical data locally
- [ ] Implement offline-first approach
- [ ] Sync pending data when online
- [ ] Handle API errors gracefully
- [ ] Show loading states

### Navigation
- [ ] Use named routes with constants
- [ ] Define routes in `app_routes.dart`
- [ ] Register routes in `app_pages.dart`
- [ ] Use appropriate transitions
- [ ] Clean up navigation stack properly

### Error Handling
- [ ] Wrap API calls in try-catch
- [ ] Show user-friendly error messages
- [ ] Log errors for debugging
- [ ] Handle network errors
- [ ] Handle authentication errors

### Performance
- [ ] Use lazy loading for controllers
- [ ] Optimize list rendering with keys
- [ ] Cache images and assets
- [ ] Minimize rebuild scope with `Obx()`
- [ ] Avoid unnecessary rebuilds

### Testing
- [ ] Write unit tests for controllers
- [ ] Write widget tests for views
- [ ] Test repository methods
- [ ] Test offline scenarios
- [ ] Test error handling

---

## 🚀 Quick Start Guide

### 1. Initialize New Project

```bash
flutter create my_app
cd my_app
```

### 2. Update `pubspec.yaml`

Add all dependencies from the Tech Stack section.

### 3. Create Directory Structure

```bash
mkdir -p lib/app/{data/{models,providers,repositories},modules,routes,services,theme,utils,widgets}
```

### 4. Set Up Core Services

Copy and adapt:
- `dependency_injection.dart`
- `storage_service.dart`
- `connectivity_service.dart`
- `api_provider.dart`

### 5. Configure App Entry Point

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DependencyInjection.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      translations: AppTranslations(),
      locale: Locale('en'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
```

### 6. Create First Feature

Follow the Feature Implementation Guide to create your first module.

---

## 📚 Additional Resources

### GetX Documentation
- [GetX Official Docs](https://github.com/jonataslaw/getx)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)

### Hive Documentation
- [Hive Docs](https://docs.hivedb.dev/)

### Flutter Best Practices
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---

## 🤝 Contributing Guidelines

When extending this template:
1. Follow the existing structure
2. Keep concerns separated
3. Extract reusable components
4. Document your code
5. Write tests
6. Update this template document

---

## 📝 Notes

- This template emphasizes **offline-first** architecture
- Uses **GetX** for state management (can be adapted to other solutions)
- Follows **clean architecture** principles
- Prioritizes **code reusability** and **maintainability**
- Designed for **scalability** and **team collaboration**

---

**Last Updated:** November 2025  
**Version:** 1.0.0  
**Maintained by:** Your Team

