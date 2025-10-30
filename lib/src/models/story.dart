import 'section.dart';
import 'quiz.dart';

class Story {
  final String id;
  final String title;
  final String authorId; // teacher owner id
  final String language; // "en" / "fr" / "ar"
  final String level; // KG1, Year1, ...
  final List<String> keywords;
  final List<Section> sections;
  final Quiz? quiz; // may be null
  final bool published; // whether available to learners
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.id,
    required this.title,
    required this.authorId,
    required this.language,
    required this.level,
    required this.keywords,
    required this.sections,
    this.quiz,
    this.published = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authorId': authorId,
      'language': language,
      'level': level,
      'keywords': keywords.join(','),
      'published': published ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Story.fromMap(
    Map<String, dynamic> m, {
    required List<Section> sections,
    Quiz? quiz,
  }) {
    return Story(
      id: m['id'],
      title: m['title'],
      authorId: m['authorId'],
      language: m['language'],
      level: m['level'],
      keywords: (m['keywords'] as String).isEmpty
          ? []
          : (m['keywords'] as String).split(','),
      sections: sections,
      quiz: quiz,
      published: m['published'] == 1,
      createdAt: DateTime.parse(m['createdAt']),
      updatedAt: DateTime.parse(m['updatedAt']),
    );
  }
}
