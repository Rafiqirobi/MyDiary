import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/services/db_service.dart';

class AddEntryPage extends StatefulWidget {
  final DiaryEntry? entry;
  AddEntryPage({this.entry});

  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedMood = '🙂';
  List<String> moods = ['🙂', '😊', '😢', '😡', '😴', '😃'];
  final dbService = DBService();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      titleController.text = widget.entry!.title;
      contentController.text = widget.entry!.content;
      selectedMood = widget.entry!.mood;
    }
  }

  void saveEntry() async {
    final now = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    if (widget.entry != null) {
      final updatedEntry = DiaryEntry(
        id: widget.entry!.id,
        title: titleController.text,
        content: contentController.text,
        date: now,
        mood: selectedMood,
      );
      await dbService.updateEntry(updatedEntry);
    } else {
      final newEntry = DiaryEntry(
        title: titleController.text,
        content: contentController.text,
        date: now,
        mood: selectedMood,
      );
      await dbService.insertEntry(newEntry);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry != null ? "Edit Entry" : "New Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title"
                )
              ),
            TextField(
              controller: contentController, 
              maxLines: 5, 
              decoration: InputDecoration(
                labelText: "Content"
                )
              ),
              
              SizedBox(height: 10), // 🌟 add spacing before mood row

              Row(
                children: moods.map((mood) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedMood = mood);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: selectedMood == mood ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(mood, style: TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveEntry, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}