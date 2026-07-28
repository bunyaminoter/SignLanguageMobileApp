import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/dictionary_word.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dictionary.db');

    // Faz 5 (Geliştirme Aşaması) için cihazdaki mevcut veritabanını silip
    // her seferinde Asset'ten yenisini kopyalıyoruz (Mock Migration).
    final exists = await databaseExists(path);
    if (exists) {
      debugPrint('Eski veritabanı siliniyor (Geliştirme Modu)...');
      await deleteDatabase(path);
    }

    debugPrint('Veritabanı oluşturuluyor, assetlerden kopyalanıyor...');
    try {
      await Directory(dirname(path)).create(recursive: true);
      
      ByteData data = await rootBundle.load(join('assets', 'database', 'dictionary.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      await File(path).writeAsBytes(bytes, flush: true);
      debugPrint('Kopyalama başarılı.');
    } catch (e) {
      debugPrint('Veritabanı kopyalanırken hata oluştu: $e');
    }

    return await openDatabase(path, version: 1);
  }

  Future<List<DictionaryWord>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dictionary');
    return List.generate(maps.length, (i) {
      return DictionaryWord.fromMap(maps[i]);
    });
  }

  Future<DictionaryWord?> searchWord(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary',
      where: 'word = ?',
      whereArgs: [word.toUpperCase()],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return DictionaryWord.fromMap(maps.first);
    }
    return null;
  }
}
