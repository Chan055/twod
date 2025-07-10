import 'package:dtwo/components/card.dart';
import 'package:dtwo/providers/two_d_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(groupedTwoDEntriesProvider);
    });
    final groupedAsync = ref.watch(groupedTwoDEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 26),
        ),
        backgroundColor: const Color(0xFF5B9547),
      ),
      body: groupedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (grouped) {
          final dates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Newest first

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final items = grouped[date]!;

              // Sort by timeSlot order
              final timeSlotsOrder = [
                '5:30',
                '6:30',
                '7:30',
                '8:30',
                '9:30',
                '10:30'
              ];

              final sortedItems = [...items]..sort((a, b) {
                  return timeSlotsOrder
                      .indexOf(a.timeSlot)
                      .compareTo(timeSlotsOrder.indexOf(b.timeSlot));
                });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    DateFormat('dd/MMM/yyyy').format(DateTime.parse(date)),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB3DE6B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 30,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      final entry = sortedItems[index];
                      return CardComponents.GetCard(
                        time: entry.timeSlot,
                        number: entry.number.toString(),
                        // Remove fixed width and height to fill grid cell
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
