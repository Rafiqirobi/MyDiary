import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String selectedMood = '😄';
  File? selectedImage;
  final picker = ImagePicker();
  final dbService = DBService();

  final List<Map<String, String>> moodOptions = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😱', 'label': 'Fear'},
    {'emoji': '😲', 'label': 'Surprise'},
    {'emoji': '🤢', 'label': 'Disgust'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      titleController.text = widget.entry!.title;
      contentController.text = widget.entry!.content;
      selectedMood = widget.entry!.mood;
      if (widget.entry!.imagePath != null) {
        selectedImage = File(widget.entry!.imagePath!);
      }
    }
  }

  Future<void> pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Image Source"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: Icon(Icons.camera_alt),
            label: Text("Camera"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: Icon(Icons.photo_library),
            label: Text("Gallery"),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  void saveEntry() async {
    final now = DateTime.now();

    final DiaryEntry entry = DiaryEntry(
      id: widget.entry?.id,
      title: titleController.text,
      content: contentController.text,
      date: now,
      mood: selectedMood,
      imagePath: selectedImage?.path,
    );

    if (widget.entry != null) {
      await dbService.updateEntry(entry);
    } else {
      await dbService.insertEntry(entry);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMoodMap = moodOptions.firstWhere(
      (m) => m['emoji'] == selectedMood,
      orElse: () => moodOptions[0],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? "Edit Entry" : "New Entry"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Content",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Text("Mood", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, String>>(
                  isExpanded: true,
                  value: selectedMoodMap,
                  items: moodOptions.map((mood) {
                    return DropdownMenuItem<Map<String, String>>(
                      value: mood,
                      child: Row(
                        children: [
                          Text(mood['emoji']!, style: TextStyle(fontSize: 22)),
                          SizedBox(width: 12),
                          Text(mood['label']!, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMood = value['emoji']!;
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage!,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveEntry,
                child: Text("Save", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
