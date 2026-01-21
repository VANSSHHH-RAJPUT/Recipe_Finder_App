import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_app/core/utils/list_utils.dart';

void main() {
  group('normalizeStringList', () {
    test('trims, deduplicates, and sorts values', () {
      final result = normalizeStringList(['  Apple', 'banana ', 'apple', '']);

      expect(result, ['Apple', 'banana']);
    });

    test('returns empty list when values are null', () {
      final result = normalizeStringList(null);

      expect(result, isEmpty);
    });
  });

  group('haveSameItemsIgnoreCase', () {
    test('returns true for same lists ignoring case', () {
      final first = ['Apple', 'BANANA'];
      final second = ['apple', 'banana'];

      expect(haveSameItemsIgnoreCase(first, second), isTrue);
    });

    test('returns false for different lists', () {
      final first = ['Apple'];
      final second = ['Orange'];

      expect(haveSameItemsIgnoreCase(first, second), isFalse);
    });
  });
}
