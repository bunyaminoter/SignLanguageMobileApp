import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // sqflite_ffi'yi başlat
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  // Veritabanı dosyasının yolu
  final dbDir = Directory('assets/database');
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }
  final dbPath = absolute(join(dbDir.path, 'dictionary.db'));

  // Varsa eskisini sil
  if (await File(dbPath).exists()) {
    await File(dbPath).delete();
    print('Eski veritabanı silindi.');
  }

  // Veritabanını oluştur ve aç
  var db = await databaseFactory.openDatabase(dbPath);

  // Tabloyu oluştur
  await db.execute('''
    CREATE TABLE dictionary (
      id TEXT PRIMARY KEY,
      word TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      videoUrl TEXT
    )
  ''');
  print('Tablo oluşturuldu.');

  // AppConstants.aslClassLabels gibi statik listemizi buraya alalım:
  final labels = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'Hello', 'Thank You', 'Yes', 'No', 'Please', 'Sorry',
    'Name', 'Sign', 'Deaf', 'Hearing', 'Learn', 'Help'
  ];
  final categoriesList = ['Genel', 'Nesneler', 'Eylemler', 'Sorular', 'Zaman', 'Duygular'];

  // Verileri ekle
  var batch = db.batch();
  final r2BaseUrl = 'https://pub-myasl-r2.r2.dev';

  for (int i = 0; i < labels.length; i++) {
    final label = labels[i];
    final cat = categoriesList[i % categoriesList.length];
    final difficulty = i % 3 == 0 ? 'Kolay' : (i % 3 == 1 ? 'Orta' : 'Zor');
    final description = '$label kelimesinin Amerikan İşaret Dilindeki (ASL) karşılığı.';
    
    // Cloudflare R2 için URL oluştur
    final formattedName = label.toLowerCase().replaceAll(' ', '_');
    final videoUrl = '$r2BaseUrl/$formattedName.mp4';
    
    batch.insert('dictionary', {
      'id': i.toString(),
      'word': label.toUpperCase(),
      'category': cat,
      'description': description,
      'difficulty': difficulty,
      'videoUrl': videoUrl,
    });
  }
  
  await batch.commit();
  print('${labels.length} adet kelime veritabanına eklendi.');

  await db.close();
  print('Veritabanı başarıyla oluşturuldu: $dbPath');
}
