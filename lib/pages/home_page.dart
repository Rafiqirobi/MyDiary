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
  List<DiaryEntry> filteredEntries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() async {
    final data = await dbService.getEntries();
    setState(() {
      entries = data;
      filteredEntries = data;
    });
  }

  void filterEntries(String query) {
    final results = entries.where((entry) {
      final titleMatch = entry.title.toLowerCase().contains(query.toLowerCase());
      final contentMatch = entry.content.toLowerCase().contains(query.toLowerCase());
      final moodMatch = entry.mood.contains(query); // emoji match
      return titleMatch || contentMatch || moodMatch;
    }).toList();

    setState(() {
      filteredEntries = results;
    });
  }

  Map<String, List<DiaryEntry>> groupEntriesByDate(List<DiaryEntry> entries) {
    Map<String, List<DiaryEntry>> grouped = {};
    for (var entry in entries) {
      String dateOnly = entry.date.split('–')[0].trim();
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = groupEntriesByDate(filteredEntries);

    return Scaffold(
      appBar: AppBar(title: Text("My Diary")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search diary...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: filterEntries,
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(child: Text("No entries found"))
                : ListView(
                    children: groupedEntries.entries.map((group) {
                      final date = group.key;
                      final entriesOnDate = group.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              '🗓️ $date',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...entriesOnDate.map((entry) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(entry.mood, style: TextStyle(fontSize: 24)),
                                          SizedBox(width: 8),
                                          Text(
                                            entry.title,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => AddEntryPage(entry: entry)),
                                              );
                                              loadEntries();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              final confirmed = await showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text('Confirm'),
                                                  content: Text('Delete this entry?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                await dbService.deleteEntry(entry.id!);
                                                loadEntries();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Entry deleted'),
                                                    backgroundColor: Colors.red,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    entry.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    entry.date,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
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
