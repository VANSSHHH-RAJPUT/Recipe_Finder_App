import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityNotifierProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>(
      (ref) => ConnectivityNotifier(),
    );

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(false) {
    _subscription = _connectivity.onConnectivityChanged.listen(_handleResults);
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStateFromList(results);
  }

  void _handleResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return;
    _updateStateFromList(results);
  }

  void _updateStateFromList(List<ConnectivityResult> results) {
    final anyOnline = results.any(
      (result) => result != ConnectivityResult.none,
    );
    state = !anyOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
