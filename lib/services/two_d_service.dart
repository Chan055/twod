import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TwoDService {
  static const String baseUrl = 'https://two-d.onrender.com/api/two-d';

  static Future<List<Map<String, dynamic>>> fetchNumbers() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      final now = DateTime.now().toLocal();
      print("Current local time: $now");
      // Filter items by date (ignore time)
      final filtered = data
          .where((item) {
            final date = DateTime.parse(item['date']);
            print("Item date: $date");
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          })
          .map((item) => item as Map<String, dynamic>)
          .toList();

      print("filtered items $filtered");
      return filtered;
    } else {
      throw Exception("Failed to load numbers");
    }
  }

  static Future<void> uploadNumber(
      String timeSlot, String number, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'timeSlot': timeSlot,
        'number': number, // <-- now a string, not int
      }),
    );
    if (response.statusCode == 401) {
      throw Exception(
        "Unauthorized: Please check your token.",
      );
    }

    if (response.statusCode != 201) {
      throw Exception(
        "Upload failed: ${json.decode(response.body)['message']}",
      );
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
      fetchGroupedByDate() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var item in data) {
        final date = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(item['date']));
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(item);
      }
      return grouped;
    } else {
      throw Exception("Failed to load grouped data");
    }
  }
}
