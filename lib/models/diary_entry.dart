class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;

  DiaryEntry({this.id, required this.title, required this.content, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content, 'date': date};
  }
}
