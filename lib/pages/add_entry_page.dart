import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/services/db_service.dart';

class AddEntryPage extends StatelessWidget {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dbService = DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: contentController, maxLines: 5, decoration: InputDecoration(labelText: "Content")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final now = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
                final entry = DiaryEntry(title: titleController.text, content: contentController.text, date: now);
                await dbService.insertEntry(entry);
                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
