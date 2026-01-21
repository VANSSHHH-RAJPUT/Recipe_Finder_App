List<String> normalizeStringList(List<String>? values) {
  if (values == null) return const [];
  final map = <String, String>{};
  for (final raw in values) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    final key = trimmed.toLowerCase();
    map.putIfAbsent(key, () => trimmed);
  }
  final sortedKeys = map.keys.toList()..sort((a, b) => a.compareTo(b));
  return sortedKeys.map((key) => map[key]!).toList();
}

bool haveSameItemsIgnoreCase(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].toLowerCase() != b[i].toLowerCase()) {
      return false;
    }
  }
  return true;
}
