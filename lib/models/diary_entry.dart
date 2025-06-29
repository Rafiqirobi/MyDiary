class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood; // 😊 😢 etc.

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood = '🙂', // default mood
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      mood: map['mood'] ?? '🙂',
    );
  }
}
