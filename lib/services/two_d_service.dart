import 'package:dtwo/models/twoD.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TwoDService {
  static const String baseUrl = 'https://two-d.onrender.com/api/two-d';
  static const String adminUrl = 'https://two-d.onrender.com/api/two-d/admin';

  static Future<List<TwoDEntry>> fetchEntriesWithAuth(String token) async {
    final response = await http.get(
      Uri.parse('$adminUrl/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => TwoDEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch entries: ${response.statusCode}');
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
}
