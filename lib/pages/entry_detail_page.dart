import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/pages/add_entry_page.dart';
import 'package:mydiary/services/db_service.dart';

class EntryDetailPage extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onUpdated;

  EntryDetailPage({required this.entry, required this.onUpdated});

  final DBService dbService = DBService();

  String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, h:mm a').format(date);
  }

  void showDeleteConfirmation(BuildContext context) async {
    await dbService.deleteEntry(entry.id!);
    onUpdated();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await dbService.insertEntry(entry);
            onUpdated();
          },
        ),
      ),
    );
  }

  void editEntry(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntryPage(entry: entry),
      ),
    );
    onUpdated();
    Navigator.pop(context); // Close detail page after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry Detail"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => editEntry(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePath != null && entry.imagePath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(entry.imagePath!),
                    fit: BoxFit.contain, // Show full image, scale to width
                    width: double.infinity,
                  ),
                ),
              ),
            Text(entry.mood, style: TextStyle(fontSize: 32)),
            SizedBox(height: 12),
            Text(
              entry.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              formatDate(entry.date),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              entry.content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
