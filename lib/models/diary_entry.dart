class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String? imagePath; // ← New field

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood = '🙂',
    this.imagePath, // ← New field in constructor
  });

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      mood: map['mood'] ?? '🙂',
      imagePath: map['imagePath'], // ← Load image path
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
      'imagePath': imagePath, // ← Save image path
    };
  }
}
