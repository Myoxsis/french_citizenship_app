import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

class HeartsState {
  final int hearts;
  final DateTime? nextRegen;
  const HeartsState({required this.hearts, this.nextRegen});
}

final heartsControllerProvider =
    StateNotifierProvider<HeartsController, HeartsState>(
  (ref) => HeartsController(ref),
);

class HeartsController extends StateNotifier<HeartsState> {
  static const int maxHearts = 5;
  static const Duration regenDuration = Duration(minutes: 30);

  final Ref _ref;
  Timer? _timer;

  HeartsController(this._ref)
      : super(const HeartsState(hearts: maxHearts)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = _ref.read(preferencesServiceProvider);
    final count = await prefs.getHeartsCount();
    final ts = await prefs.getNextHeartTimestamp();
    state = HeartsState(
      hearts: count,
      nextRegen:
          ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts),
    );
    _applyRecovery();
  }

  void _applyRecovery() {
    var hearts = state.hearts;
    DateTime? next = state.nextRegen;
    final now = DateTime.now();
    if (next != null) {
      while (!now.isBefore(next)) {
        hearts++;
        if (hearts >= maxHearts) {
          hearts = maxHearts;
          next = null;
          break;
        } else {
          next = next.add(regenDuration);
        }
      }
    }
    state = HeartsState(hearts: hearts, nextRegen: next);
    _save();
    _setupTimer();
  }

  void _setupTimer() {
    _timer?.cancel();
    final next = state.nextRegen;
    if (next != null) {
      final now = DateTime.now();
      final diff = next.difference(now);
      _timer = Timer(diff.isNegative ? Duration.zero : diff, _applyRecovery);
    }
  }

  Future<void> _save() async {
    final prefs = _ref.read(preferencesServiceProvider);
    await prefs.setHeartsState(state.hearts, state.nextRegen);
  }

  bool spend(int amount) {
    _applyRecovery();
    if (state.hearts < amount) return false;
    final now = DateTime.now();
    var hearts = state.hearts - amount;
    DateTime? next = state.nextRegen;
    if (hearts < maxHearts && next == null) {
      next = now.add(regenDuration);
    }
    state = HeartsState(hearts: hearts, nextRegen: next);
    _save();
    _setupTimer();
    return true;
  }

  Future<void> addHeart() async {
    _applyRecovery();
    if (state.hearts >= maxHearts) return;
    var hearts = state.hearts + 1;
    DateTime? next = state.nextRegen;
    if (hearts >= maxHearts) {
      hearts = maxHearts;
      next = null;
    }
    state = HeartsState(hearts: hearts, nextRegen: next);
    await _save();
    _setupTimer();
  }

  Future<void> reset() async {
    state = const HeartsState(hearts: maxHearts, nextRegen: null);
    await _save();
    _setupTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

