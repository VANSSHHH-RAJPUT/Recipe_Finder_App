import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'backend/core/storage_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(StorageKeys.recipesCacheBox);
  await Hive.openBox<String>(StorageKeys.favoritesBox);
  await Hive.openBox<String>(StorageKeys.settingsBox);

  runApp(const ProviderScope(child: RecipeFinderApp()));
}
