class Question {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex; // index to options

  Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap(String quizId, int order) {
    return {
      'id': id,
      'quizId': quizId,
      'prompt': prompt,
      'options': options.join('|||'), // simple serialization for SQLite
      'correctIndex': correctIndex,
      'orderIndex': order,
    };
  }

  factory Question.fromMap(Map<String, dynamic> m) {
    return Question(
      id: m['id'],
      prompt: m['prompt'],
      options: (m['options'] as String).split('|||'),
      correctIndex: m['correctIndex'],
    );
  }
}
