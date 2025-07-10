import 'dart:async';

import 'package:dtwo/models/twoD.dart';
import 'package:dtwo/providers/token_provider.dart';
import 'package:dtwo/services/two_d_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayTwoDNotifier extends StateNotifier<AsyncValue<List<TwoDEntry>>> {
  final Ref ref;

  TodayTwoDNotifier(this.ref) : super(const AsyncLoading()) {
    _loadToday();
  }

  Future<void> _loadToday() async {
    try {
      final token = ref.read(jwtProvider);
      print("token: $token");

      if (token == null) {
        print("token is null, cannot fetch today's entries");
        return;
      }

      final allEntries = await TwoDService.fetchEntriesWithAuth(token);
      final now = DateTime.now();

      final todayEntries = allEntries.where((entry) {
        return entry.date.year == now.year &&
            entry.date.month == now.month &&
            entry.date.day == now.day;
      }).toList();

      state = AsyncData(todayEntries);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // 👇 Call this to simulate optimistic update
  void optimisticAdd(TwoDEntry newEntry) {
    if (state case AsyncData(:final value)) {
      state = AsyncData([...value, newEntry]);
    }
  }

  // 👇 Reload from backend after real upload
  Future<void> refresh() async {
    state = const AsyncLoading();
    await _loadToday();
  }
}


  // Future<void> submitEntry(String slot, String number, String jwt) async {
  //   try {
  //     final newEntry = await TwoDService.createEntry(
  //       jwt: jwt,
  //       timeSlot: slot,
  //       number: number,
  //     );

  //     optimisticAdd(newEntry);
  //   } catch (e, st) {
  //     state = AsyncError(e, st);
  //     rethrow; // So the UI knows something went wrong
  //   }
  // }