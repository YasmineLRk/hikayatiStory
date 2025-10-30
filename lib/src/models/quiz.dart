import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  Quiz({required this.id, required this.title, required this.questions});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory Quiz.fromMap(Map<String, dynamic> m, List<Question> questions) {
    return Quiz(id: m['id'], title: m['title'], questions: questions);
  }
}
