import 'package:dtwo/components/card.dart';
import 'package:dtwo/models/twoD.dart';
import 'package:dtwo/providers/token_provider.dart';
import 'package:dtwo/providers/two_d_list_provider.dart';
import 'package:dtwo/services/two_d_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd/MMM/yyyy').format(DateTime.now());
    final jwt = ref.watch(jwtProvider);
    final List<String> timeSlots = [
      '5:30',
      '6:30',
      '7:30',
      '8:30',
      '9:30',
      '10:30',
    ];

    final asyncEntries = ref.watch(todayTwoDEntriesProvider);
    final notifier = ref.read(todayTwoDEntriesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut(); // <=== wait here
                ref.read(jwtProvider.notifier).clearToken();
                Navigator.pushReplacementNamed(context, "/");
              }
            }),
        title: Center(
          child: const Text(
            "2D",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 26),
          ),
        ),
        backgroundColor: const Color(0xFF5B9547),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/history");
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            today,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB3DE6B),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: asyncEntries.when(
              data: (entries) {
                // Convert list to Map<timeSlot, number>
                final slotMap = {
                  for (var e in entries) e.timeSlot: e.number,
                };

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: timeSlots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 30,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final slot = timeSlots[index];
                    final number = slotMap[slot];

                    return GestureDetector(
                      onTap: () {
                        if (number == null) {
                          if (jwt == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in to enter numbers'),
                              ),
                            );
                            return;
                          }
                          // Show input dialog to enter number
                          _showInputDialog(slot, jwt, context);
                        }
                      },
                      child: CardComponents.GetCard(
                        time: slot,
                        number: number != null ? number.toString() : '??',
                        height: 77,
                        // width: not set, uses double.infinity and fits grid cell
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Failed to load entries: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B9547),
        foregroundColor: Color(0xFF2B2D42),
        // onPressed: () {
        //   _showInputDialog(timeSlots[0], jwt ?? '');
        // },
        onPressed: () async {
          await notifier.refresh();
          ;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refreshing...')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showInputDialog(String slot, String jwt, BuildContext context) {
    final notifier = ref.read(todayTwoDEntriesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter number for $slot'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter 2D number',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = _controller.text.trim();

                if (input.isEmpty ||
                    input.length > 2 ||
                    int.tryParse(input) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid 2D number')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
// Then send to backend
                  await TwoDService.uploadNumber(slot, input, jwt);

// Then refresh real data
                  await notifier.refresh();
                  // Call the service to upload the number

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Entry saved for $slot')),
                  );
                } catch (e) {
                  print("Error uploading number: $e");
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
