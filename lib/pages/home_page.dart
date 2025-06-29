import 'package:flutter/material.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/pages/add_entry_page.dart';
import 'package:mydiary/pages/profile_page.dart';
import 'package:mydiary/pages/settings_page.dart';
import 'package:mydiary/services/db_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBService dbService = DBService();
  List<DiaryEntry> entries = [];

  void loadEntries() async {
    final data = await dbService.getEntries();
    setState(() => entries = data);
  }

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Diary")),
      body: entries.isEmpty
          ? Center(child: Text("No entries yet"))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.date),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddEntryPage(entry: entry)),
                          );
                          loadEntries(); // refresh list after editing
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await dbService.deleteEntry(entry.id!);
                          loadEntries(); // refresh list after deletion
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEntryPage()));
          loadEntries();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Diary"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
          }
        },
      ),
    );
  }
}
