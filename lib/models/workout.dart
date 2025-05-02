class Workout {
  final String name;
  final DateTime date;

  Workout({required this.name, required this.date});

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
