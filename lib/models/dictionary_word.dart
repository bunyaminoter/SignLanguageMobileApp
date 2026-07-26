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
}
