import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dtwo/services/two_d_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _groupedFuture;

  @override
  void initState() {
    super.initState();
    _groupedFuture = TwoDService.fetchGroupedByDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D2235),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _groupedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final grouped = snapshot.data!;
          final dates =
              grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // newest date first

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final items = grouped[date]!;

              // Sort items by timeSlot order
              final List<String> timeSlotsOrder = [
                '5:30',
                '6:30',
                '7:30',
                '8:30',
                '9:30',
                '10:30',
              ];

              final sortedItems = [...items]..sort((a, b) {
                final aIndex = timeSlotsOrder.indexOf(a['timeSlot']);
                final bIndex = timeSlotsOrder.indexOf(b['timeSlot']);
                return aIndex.compareTo(bIndex);
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    DateFormat('dd/MMM/yyyy').format(DateTime.parse(date)),
                    style: const TextStyle(
                      color: Color(0xFFB8C928),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children:
                        sortedItems.map((entry) {
                          return Card(
                            color: const Color(0xFF6BA147),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry['timeSlot'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                const Divider(
                                  thickness: 1,
                                  color: Colors.black54,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry['number'].toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
