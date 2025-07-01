class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final String mood; // 😊 😢 etc.

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood = '🙂', // default mood
  });

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']), // convert from String
      mood: map['mood'] ?? '🙂',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(), // save as String
      'mood': mood,
    };
  }
}
