class TwoDEntry {
  final String id;
  final int number;
  final String timeSlot;
  final DateTime date;

  TwoDEntry({
    required this.id,
    required this.number,
    required this.timeSlot,
    required this.date,
  });

  factory TwoDEntry.fromJson(Map<String, dynamic> json) {
    return TwoDEntry(
      id: json['_id'],
      number: json['number'],
      timeSlot: json['timeSlot'],
      date: DateTime.parse(json['date']),
    );
  }
}

class TwoDEntryGrouped {
  final String date;
  final List<TwoDEntry> entries;

  TwoDEntryGrouped({
    required this.date,
    required this.entries,
  });

  factory TwoDEntryGrouped.fromJson(Map<String, dynamic> json) {
    return TwoDEntryGrouped(
      date: json['date'],
      entries: (json['entries'] as List)
          .map((entry) => TwoDEntry.fromJson(entry))
          .toList(),
    );
  }
}
