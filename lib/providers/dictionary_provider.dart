import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/dictionary_word.dart';

class DictionaryProvider extends ChangeNotifier {
  final List<DictionaryWord> _words = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';

  List<DictionaryWord> get allWords => _words;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

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
    _loadSampleWords();
  }

  void _loadSampleWords() {
    final labels = AppConstants.aslClassLabels;
    final categoriesList = ['Genel', 'Nesneler', 'Eylemler', 'Sorular', 'Zaman', 'Duygular'];
    
    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      final cat = categoriesList[i % categoriesList.length];
      _words.add(
        DictionaryWord(
          id: i.toString(),
          word: label.toUpperCase(),
          category: cat,
          description: '$label kelimesinin Amerikan İşaret Dilindeki (ASL) karşılığı.',
          difficulty: i % 3 == 0 ? 'Kolay' : (i % 3 == 1 ? 'Orta' : 'Zor'),
        ),
      );
    }
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
