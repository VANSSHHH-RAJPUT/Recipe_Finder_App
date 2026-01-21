import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage_keys.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._box);

  final Box<String> _box;

  String? getViewModePreference() =>
      _box.get(StorageKeys.viewModePreferenceKey);

  Future<void> saveViewModePreference(String mode) =>
      _box.put(StorageKeys.viewModePreferenceKey, mode);
}
