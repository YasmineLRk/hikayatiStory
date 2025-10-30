import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hikayati_phase1.db');
    _db = await openDatabase(path, version: 1, onCreate: _create);
    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    // minimal tables: users, stories, sections, quizzes, questions
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        displayName TEXT,
        role TEXT,
        passwordHash TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE stories (
        id TEXT PRIMARY KEY,
        title TEXT,
        authorId TEXT,
        language TEXT,
        level TEXT,
        keywords TEXT,
        published INTEGER,
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE sections (
        id TEXT PRIMARY KEY,
        storyId TEXT,
        heading TEXT,
        text TEXT,
        imageUrl TEXT,
        audioUrl TEXT,
        orderIndex INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE quizzes (
        id TEXT PRIMARY KEY,
        storyId TEXT,
        title TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        quizId TEXT,
        prompt TEXT,
        options TEXT,
        correctIndex INTEGER,
        orderIndex INTEGER
      );
    ''');
  }
}
