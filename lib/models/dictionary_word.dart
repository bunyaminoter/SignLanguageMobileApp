class DictionaryWord {
  final String id;
  final String word;
  final String category;
  final String description;
  final String difficulty;
  final String videoUrl;

  const DictionaryWord({
    required this.id,
    required this.word,
    required this.category,
    required this.description,
    this.difficulty = 'Kolay',
    this.videoUrl = '',
  });

  factory DictionaryWord.fromMap(Map<String, dynamic> map) {
    return DictionaryWord(
      id: map['id'] as String,
      word: map['word'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      videoUrl: map['videoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'category': category,
      'description': description,
      'difficulty': difficulty,
      'videoUrl': videoUrl,
    };
  }
}
