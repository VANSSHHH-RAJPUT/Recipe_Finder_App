# Recipe Finder App

Flutter recipe discovery experience built for an internship assignment. The app showcases a glassmorphism UI, Riverpod for state, and a layered architecture backed by [TheMealDB](https://www.themealdb.com/api.php).

## Architecture Overview

- **Presentation:** Flutter screens/widgets using Riverpod controllers for state.
- **Domain:** Entities (`Recipe`, `Category`, etc.) and repository contracts.
- **Data:** Remote data source (Dio + TheMealDB), Hive-backed local cache for offline support, and repositories orchestrating both sources.

## Key Features

- Browse/search/filter recipes with grid/list toggle & sort options.
- Detailed recipe view with hero transitions, tabs, and YouTube section.
- Favorites list with persistence via Hive.
- Offline caching: API responses cached locally; controllers fall back when offline.

## Tech Stack

- Flutter 3 / Dart 3
- Riverpod (`flutter_riverpod`)
- Dio + PrettyDioLogger
- Hive (offline caching & favorites)
- CachedNetworkImage, Shimmer, Flutter Animate

## Setup & Tooling

```bash
# install dependencies
flutter pub get

# run the app on a connected device/emulator
flutter run
```

### Build an APK

```bash
flutter build apk --release
```

## Testing & Coverage

Automated coverage focuses on business logic (controllers, repositories, models, utilities) and the required widgets.

```bash
# unit + widget tests w/ coverage report (coverage/lcov.info)
flutter test --coverage

# static analysis
flutter analyze
```

### Implemented Test Cases

| Category | Files |
| --- | --- |
| API service | `test/backend/data/datasources/meal_db_remote_data_source_test.dart` |
| Repository | `test/backend/data/repositories/recipe_repository_impl_test.dart` |
| Riverpod controller | `test/features/recipes/presentation/controllers/recipe_list_controller_test.dart` |
| Models | `test/backend/data/models/meal_model_test.dart` |
| Utilities | `test/core/utils/list_utils_test.dart` |
| Widgets | `test/features/recipes/presentation/widgets/{recipe_card_test,recipe_search_bar_test,favorite_button_test}.dart` |

Running `flutter test --coverage` produces coverage data under `coverage/lcov.info` (>=70% on the business logic layer).

## Submission Checklist

- [x] All assignment features implemented (list/detail/favorites, filters, offline cache, YouTube)
- [x] App runs without crashes (tested on emulator/device)
- [x] Automated tests pass (`flutter test --coverage`)
- [x] APK built and smoke-tested via `flutter build apk --release`
- [x] README updated with architecture + instructions

---
