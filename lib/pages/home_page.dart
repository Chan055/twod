import 'dart:async';
import 'package:dtwo/components/card.dart';
import 'package:dtwo/pages/history.dart';
import 'package:dtwo/services/two_d_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dtwo/providers/token_provider.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final List<String> timeSlots = [
    '5:30',
    '6:30',
    '7:30',
    '8:30',
    '9:30',
    '10:30',
  ];

  Map<String, int?> numberResults = {}; // Store as int? for safety

  final TextEditingController _numberController = TextEditingController();
  String selectedTimeSlot = '5:30';

  @override
  void initState() {
    super.initState();
    _loadNumbers();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadNumbers();
    });
  }

  Future<void> _loadNumbers() async {
    try {
      final data = await TwoDService.fetchNumbers();

      setState(() {
        numberResults = {for (var time in timeSlots) time: null};
        for (var item in data) {
          final time = item['timeSlot'];
          final number = item['number'];
          numberResults[time] = number;
        }
      });
    } catch (e) {
      print('Error loading numbers: $e');
    }
  }

  void _showInputDialog(String timeSlot, String jwt) {
    _numberController.clear();
    selectedTimeSlot = timeSlot;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFF2ECF9),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Number',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: 'Enter number',
                    counterText: '',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Text(
                    selectedTimeSlot,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA147),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    final input = _numberController.text;
                    if (input.length != 2 || int.tryParse(input) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 2-digit number.'),
                        ),
                      );
                      return;
                    }

                    try {
                      print("Token is $jwt");
                      await TwoDService.uploadNumber(
                          selectedTimeSlot, input, jwt);
                      Navigator.pop(context);
                      _loadNumbers();
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: $e')),
                      );
                    }
                  },
                  child: const Text('UPLOAD'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jwt = ref.watch(jwtProvider);
    final today = DateFormat('dd/MMM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF1D2235),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA147),
        title: const Text("2D"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            today,
            style: const TextStyle(color: Colors.yellow, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
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
                final number = numberResults[slot];

                return GestureDetector(
                  onTap: () {
                    if (number == null) {
                      _showInputDialog(slot, '${jwt}');
                    }
                  },
                  child: CardComponents.GetCard(
                      time: slot,
                      number: number != null ? number.toString() : '??'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
