/// The response of the `GET /api/activity` endpoint.
class TwoD {
  TwoD({
    this.number,
    required this.time,
  });

  /// Convert a JSON object into an [TwoD] instance.
  /// This enables type-safe reading of the API response.
  factory TwoD.fromJson(Map<String, dynamic> json) {
    return TwoD(
      number: json['participants'] as int,
      time: json['key'] as String,
    );
  }

  final int? number;
  final String time;

}