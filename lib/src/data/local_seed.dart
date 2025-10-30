import 'package:uuid/uuid.dart';
import '../models/section.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../models/story.dart';

final _uuid = Uuid();

Story createSampleStory(String authorId) {
  final s1 = Section(
    id: _uuid.v4(),
    heading: 'Once upon a time',
    text: 'A small fox lived near a river...',
    imageUrl: 'https://github.com/your-repo/image1.png',
  );
  final s2 = Section(
    id: _uuid.v4(),
    heading: 'The adventure',
    text: 'The fox decided to explore the forest...',
    imageUrl: 'https://github.com/your-repo/image2.png',
  );

  final q1 = Question(
    id: _uuid.v4(),
    prompt: 'What was the fox near?',
    options: ['A mountain', 'A river', 'A desert', 'A city'],
    correctIndex: 1,
  );

  final quiz = Quiz(id: _uuid.v4(), title: 'Comprehension', questions: [q1]);

  return Story(
    id: _uuid.v4(),
    title: 'The Little Fox',
    authorId: authorId,
    language: 'en',
    level: 'Year1',
    keywords: ['fox', 'adventure'],
    sections: [s1, s2],
    quiz: quiz,
    published: true,
  );
}
