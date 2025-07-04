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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Entry?"),
        content: Text("This action cannot be undone. Do you want to continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
  }

  void editEntry(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEntryPage(entry: entry)),
    );
    onUpdated();
    Navigator.pop(context); // close detail page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry Detail"),
        actions: [
          IconButton(icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color), onPressed: () => editEntry(context)),
          IconButton(icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color), onPressed: () => showDeleteConfirmation(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (entry.imagePath != null && entry.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(entry.imagePath!),
                  width: double.infinity,
                  height: 220,
                  
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entry.mood, style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      formatDate(entry.date),
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Divider(height: 30, thickness: 1),
                    Text(
                      entry.content,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
