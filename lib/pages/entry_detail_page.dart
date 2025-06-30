import 'package:flutter/material.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/pages/add_entry_page.dart';
import 'package:mydiary/services/db_service.dart';

class EntryDetailPage extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onUpdated;

  EntryDetailPage({required this.entry, required this.onUpdated});

  final DBService dbService = DBService();

  void undoDelete(BuildContext context) async {
    await dbService.insertEntry(entry);
    onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEntryPage(entry: entry)),
                );
                onUpdated();
                Navigator.pop(context);
              } else if (value == 'delete') {
                await dbService.deleteEntry(entry.id!);
                onUpdated();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => undoDelete(context),
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.mood, style: TextStyle(fontSize: 40)),
            SizedBox(height: 10),
            Text(
              entry.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              entry.date,
              style: TextStyle(color: Colors.grey),
            ),
            Divider(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry.content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
