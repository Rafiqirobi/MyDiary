import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/models/diary_entry.dart';
import 'package:mydiary/pages/add_entry_page.dart';
import 'package:mydiary/pages/entry_detail_page.dart';
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

  String selectedMood = 'All';
  String sortOption = 'Latest';

  final List<Map<String, String>> moodOptions = [
    {'emoji': '😄', 'label': 'Happiness'},
    {'emoji': '😢', 'label': 'Sadness'},
    {'emoji': '😠', 'label': 'Anger'},
    {'emoji': '😱', 'label': 'Fear'},
    {'emoji': '😲', 'label': 'Surprise'},
    {'emoji': '🤢', 'label': 'Disgust'},
  ];

  List<String> get moods => ['All', ...moodOptions.map((m) => m['emoji']!)];
  List<String> sortOptions = ['Latest', 'Oldest'];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() async {
    final data = await dbService.getEntries();
    if (!mounted) return;
    setState(() {
      entries = data;
      applyFilters();
    });
  }

  void applyFilters() {
    List<DiaryEntry> results = entries;

    if (selectedMood != 'All') {
      results = results.where((entry) => entry.mood == selectedMood).toList();
    }

    final query = searchController.text.toLowerCase();
    results = results.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.content.toLowerCase().contains(query) ||
          entry.mood.contains(query);
    }).toList();

    switch (sortOption) {
      case 'Oldest':
        results.sort((a, b) => a.date.compareTo(b.date));
        break;
      default:
        results.sort((a, b) => b.date.compareTo(a.date));
    }

    if (!mounted) return;
    setState(() {
      filteredEntries = results;
    });
  }

  Map<String, List<DiaryEntry>> groupEntriesByDate(List<DiaryEntry> entries) {
    Map<String, List<DiaryEntry>> grouped = {};
    for (var entry in entries) {
      String dateOnly = DateFormat('d MMMM yyyy').format(entry.date);
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(entry);
    }
    return grouped;
  }

  void undoDelete(DiaryEntry entry) async {
    await dbService.insertEntry(entry);
    loadEntries();
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, h:mm a').format(date).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = groupEntriesByDate(filteredEntries);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Diary"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
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
              onChanged: (_) => applyFilters(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: selectedMood,
                  items: moods.map((mood) {
                    String label = mood == 'All'
                        ? 'All'
                        : moodOptions.firstWhere((m) => m['emoji'] == mood)['label']!;
                    return DropdownMenuItem(
                      value: mood,
                      child: mood == 'All'
                          ? Text('All')
                          : Row(
                              children: [
                                Text(mood),
                                SizedBox(width: 8),
                                Text(label),
                              ],
                            ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedMood = value!);
                    applyFilters();
                  },
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortOption,
                      items: sortOptions.map((opt) {
                        IconData icon = opt == 'Latest' ? Icons.arrow_downward : Icons.arrow_upward;
                        return DropdownMenuItem(
                          value: opt,
                          child: Row(
                            children: [
                              Icon(icon, size: 18),
                              SizedBox(width: 8),
                              Text(opt),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => sortOption = value!);
                        applyFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      "No entries found",
                      style: TextStyle(color: textColor),
                    ),
                  )
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                          ...entriesOnDate.map((entry) {
                            return Dismissible(
                              key: Key(entry.id.toString()),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await dbService.deleteEntry(entry.id!);
                                loadEntries();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Entry deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: Colors.green,
                                      onPressed: () => undoDelete(entry),
                                    ),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EntryDetailPage(
                                        entry: entry,
                                        onUpdated: loadEntries,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      if (!theme.brightness.toString().contains('dark'))
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (entry.imagePath != null && entry.imagePath!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            File(entry.imagePath!),
                                            height: 200,
                                            width: double.infinity,
                                          ),
                                        ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(entry.mood, style: TextStyle(fontSize: 24)),
                                              SizedBox(width: 8),
                                              Text(
                                                entry.title,
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => AddEntryPage(entry: entry)),
                                                );
                                                loadEntries();
                                              } else if (value == 'delete') {
                                                await dbService.deleteEntry(entry.id!);
                                                loadEntries();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Entry deleted'),
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      textColor: Colors.yellow,
                                                      onPressed: () => undoDelete(entry),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        entry.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: textColor?.withOpacity(0.8)),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        formatDate(entry.date),
                                        style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
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
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEntryPage()));
          loadEntries();
        },
      ),
    );
  }
}
