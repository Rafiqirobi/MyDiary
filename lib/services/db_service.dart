import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';

class DBService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'diary.db');
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        date TEXT, -- still store as TEXT in DB (ISO8601 format)
        mood TEXT
      )
    ''');
  }

  Future<void> insertEntry(DiaryEntry entry) async {
    final db = await database;
    await db.insert(
      'diary',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getEntries() async {
    final db = await database;
    final result = await db.query('diary', orderBy: 'date DESC'); // sort by ISO8601 string
    return result.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final db = await database;
    await db.update(
      'diary',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('diary', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllEntries() async {
  final db = await database;
  await db.delete('diary');
}
}
