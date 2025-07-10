import 'package:dtwo/models/twoD.dart';
import 'package:dtwo/providers/noitifier.dart';
import 'package:dtwo/providers/token_provider.dart';
import 'package:dtwo/services/two_d_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final groupedTwoDEntriesProvider =
    FutureProvider<Map<String, List<TwoDEntry>>>((ref) async {
  final token = ref.watch(jwtProvider);

  if (token == null) throw Exception('Missing token');

  final entries = await TwoDService.fetchEntriesWithAuth(token);

  final Map<String, List<TwoDEntry>> grouped = {};

  for (var entry in entries) {
    final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
    grouped.putIfAbsent(dateKey, () => []).add(entry);
  }

  return grouped;
});

final todayTwoDEntriesProvider =
    StateNotifierProvider<TodayTwoDNotifier, AsyncValue<List<TwoDEntry>>>(
  (ref) => TodayTwoDNotifier(ref),
);

// final todayTwoDEntriesProvider = FutureProvider<List<TwoDEntry>>((ref) async {
//   print("Fetching today's entries");
//   final token = ref.watch(jwtProvider);
//   if (token == null) throw Exception('Missing token');

//   final allEntries = await TwoDService.fetchEntriesWithAuth(token);

//   final now = DateTime.now();

//   return allEntries.where((entry) {
//     return entry.date.year == now.year &&
//         entry.date.month == now.month &&
//         entry.date.day == now.day;
//   }).toList();
// });
