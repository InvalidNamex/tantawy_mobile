# 🏗️ Flutter Project Structure — GetX + MVC (Feature-Based)

This document describes a **clean, scalable folder structure** for Flutter apps using **GetX** and the **MVC pattern**.  
It’s designed for medium-to-large projects where clear separation of concerns and modularity are essential.

---

## 📁 Folder Overview

```
lib/
│
├── app/
│   ├── data/                 # Data layer (Models, Providers, Repositories)
│   ├── modules/              # Feature-based MVC modules
│   ├── routes/               # Centralized routing (GetPages, route constants)
│   ├── services/             # Global singleton services (Auth, API, etc.)
│   ├── theme/                # App-wide themes, colors, and text styles
│   ├── utils/                # Helpers, extensions, constants, and utilities
│   ├── widgets/              # Shared and reusable widgets
│   └── bindings/             # Global bindings for core services (optional)
│
├── main.dart                 # Entry point (initial bindings, GetMaterialApp)
└── app_config.dart           # Optional: environment setup (API base URL, env vars)
```

---

## 🧩 Detailed Folder Breakdown

### 1. **`lib/app/modules/` — Feature-Based Modules (MVC)**

Each feature lives in its own folder and follows the **MVC pattern** with GetX.

Example:
```
lib/app/modules/
├── auth/
│   ├── controllers/
│   │   └── auth_controller.dart
│   ├── models/
│   │   └── user_model.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   ├── views/
│   │   ├── login_view.dart
│   │   ├── register_view.dart
│   │   └── forgot_password_view.dart
│   ├── bindings/
│   │   └── auth_binding.dart
│   └── auth_routes.dart
│
├── home/
│   ├── controllers/
│   │   └── home_controller.dart
│   ├── views/
│   │   └── home_view.dart
│   ├── bindings/
│   │   └── home_binding.dart
│   └── home_routes.dart
│
└── profile/
    ├── controllers/
    │   └── profile_controller.dart
    ├── views/
    │   └── profile_view.dart
    ├── bindings/
    │   └── profile_binding.dart
    ├── models/
    │   └── profile_model.dart
    └── repositories/
        └── profile_repository.dart
```

#### 📘 Example (Auth Module)
- **Controller:** `auth_controller.dart` — business logic
- **View:** `login_view.dart` — UI screen
- **Model:** `user_model.dart` — represents user data
- **Provider:** `auth_provider.dart` — handles API calls
- **Binding:** `auth_binding.dart` — injects controller + dependencies
- **Repository:** `auth_repository.dart` — mediates between provider and controller

---

### 2. **`lib/app/data/` — Global Data Layer**

Shared models, repositories, and data sources used across modules.

```
lib/app/data/
├── models/
│   ├── base_response.dart
│   ├── error_model.dart
│   └── user_model.dart
│
├── providers/
│   ├── api_provider.dart        # Base API logic (Dio/http)
│   └── local_storage.dart       # SharedPreferences / Hive
│
└── repositories/
    ├── user_repository.dart
    ├── auth_repository.dart
    └── settings_repository.dart
```

---

### 3. **`lib/app/routes/` — Centralized Navigation**

```
lib/app/routes/
├── app_routes.dart     # Route name constants
└── app_pages.dart      # GetPage definitions
```

---

### 4. **`lib/app/services/` — Global Services**

Long-lived singletons or background logic.

```
lib/app/services/
├── auth_service.dart
├── api_service.dart
└── storage_service.dart
```

---

### 5. **`lib/app/theme/` — Theming System**

```
lib/app/theme/
├── app_theme.dart
├── colors.dart
└── text_styles.dart
```

---

### 6. **`lib/app/utils/` — Helpers, Extensions, Constants**

```
lib/app/utils/
├── constants.dart
├── date_formatter.dart
├── logger.dart
└── extensions/
    ├── string_extensions.dart
    └── widget_extensions.dart
```

---

### 7. **`lib/app/widgets/` — Reusable Widgets**

```
lib/app/widgets/
├── custom_button.dart
├── custom_textfield.dart
└── loading_indicator.dart
```

---

### 8. **`lib/app/bindings/` — Global Bindings (Optional)**

```
lib/app/bindings/
└── initial_binding.dart
```

---

## 🧠 Naming Conventions

| Type           | Example Name              | Notes |
|----------------|---------------------------|-------|
| Controller     | `home_controller.dart`     | Handles business logic |
| View           | `home_view.dart`           | UI widget (Stateless/Stateful) |
| Model          | `user_model.dart`          | Data structure |
| Binding        | `auth_binding.dart`        | Binds dependencies |
| Provider       | `api_provider.dart`        | Network or local data source |
| Repository     | `auth_repository.dart`     | Wraps provider for cleaner API |
| Service        | `auth_service.dart`        | App-wide singleton logic |
| Widget         | `custom_button.dart`       | Reusable UI element |

---

## 🧭 Example Entry Point (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AuthService().init());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My GetX App',
      initialBinding: InitialBinding(),
      initialRoute: Routes.AUTH,
      getPages: routes,
      theme: AppTheme.lightTheme,
    );
  }
}
```

---

## ✅ Benefits

- **Modular** — each feature is self-contained.
- **Scalable** — easily add/remove modules.
- **Testable** — clear separation of View, Controller, and Model.
- **Maintainable** — consistent naming and structure.
- **Team-friendly** — multiple devs can work in parallel without conflicts.

---

## 🧱 Summary

```
lib/
└── app/
    ├── data/
    ├── modules/
    ├── routes/
    ├── services/
    ├── theme/
    ├── utils/
    ├── widgets/
    └── bindings/
```

Each module follows:
```
module/
├── controllers/
├── views/
├── models/
├── providers/
├── repositories/
└── bindings/
```

---

## 🏁 Recommended Extras

- Use `flutter_lints` for consistent code style.
- Add `.env` configuration with `flutter_dotenv` for base URLs.
- Maintain `README.md` per module if it becomes complex.
- Consider adding `core/` layer if many modules share logic.

---

**Author:** Flutter GetX MVC Reference  
**Version:** 1.0  
**Last Updated:** October 2025
