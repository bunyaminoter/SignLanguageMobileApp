import 'package:flutter/foundation.dart';
import '../models/dictionary_word.dart';
import '../services/database_service.dart';

class DictionaryProvider extends ChangeNotifier {
  List<DictionaryWord> _words = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  bool _isLoading = true;

  List<DictionaryWord> get allWords => _words;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<String> get categories => [
        'Tümü',
        'Genel',
        'Nesneler',
        'Eylemler',
        'Sorular',
        'Zaman',
        'Duygular',
      ];

  DictionaryProvider() {
    loadWordsFromDatabase();
  }

  Future<void> loadWordsFromDatabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      _words = await DatabaseService().getAllWords();
    } catch (e) {
      debugPrint('Kelimeler yüklenirken hata oluştu: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<DictionaryWord> get filteredWords {
    return _words.where((word) {
      final matchesSearch = word.word.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tümü' || word.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
