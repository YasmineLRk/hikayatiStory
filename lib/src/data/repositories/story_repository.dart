import '../../models/story.dart';
import '../../models/section.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../db_provider.dart';

class StoryRepository {
  final DBProvider _dbp = DBProvider();

  // Create story: only teacher allowed (enforced by service layer)
  Future<void> createStory(Story story) async {
    final db = await _dbp.database;
    await db.insert('stories', story.toMap());
    // insert sections
    for (int i = 0; i < story.sections.length; i++) {
      await db.insert('sections', story.sections[i].toMap(story.id, i));
    }
    // insert quiz + questions if exists
    if (story.quiz != null) {
      await db.insert('quizzes', {
        'id': story.quiz!.id,
        'storyId': story.id,
        'title': story.quiz!.title,
      });
      for (int i = 0; i < story.quiz!.questions.length; i++) {
        await db.insert(
          'questions',
          story.quiz!.questions[i].toMap(story.quiz!.id, i),
        );
      }
    }
  }

  Future<void> updateStory(Story story) async {
    final db = await _dbp.database;
    await db.update(
      'stories',
      story.toMap(),
      where: 'id = ?',
      whereArgs: [story.id],
    );
    // For simplicity remove and re-add sections & quiz data (ok for phase 1)
    await db.delete('sections', where: 'storyId = ?', whereArgs: [story.id]);
    for (int i = 0; i < story.sections.length; i++) {
      await db.insert('sections', story.sections[i].toMap(story.id, i));
    }
    await db.delete('quizzes', where: 'storyId = ?', whereArgs: [story.id]);
    if (story.quiz != null) {
      await db.insert('quizzes', {
        'id': story.quiz!.id,
        'storyId': story.id,
        'title': story.quiz!.title,
      });
      await db.delete(
        'questions',
        where: 'quizId = ?',
        whereArgs: [story.quiz!.id],
      );
      for (int i = 0; i < story.quiz!.questions.length; i++) {
        await db.insert(
          'questions',
          story.quiz!.questions[i].toMap(story.quiz!.id, i),
        );
      }
    }
  }

  Future<void> deleteStory(String storyId) async {
    final db = await _dbp.database;
    await db.delete(
      'questions',
      where: 'quizId IN (SELECT id FROM quizzes WHERE storyId = ?)',
      whereArgs: [storyId],
    );
    await db.delete('quizzes', where: 'storyId = ?', whereArgs: [storyId]);
    await db.delete('sections', where: 'storyId = ?', whereArgs: [storyId]);
    await db.delete('stories', where: 'id = ?', whereArgs: [storyId]);
  }

  Future<List<Story>> listStories({
    String? q,
    String? language,
    String? level,
  }) async {
    final db = await _dbp.database;
    String where = '';
    List<dynamic> args = [];
    if (q != null) {
      where += "title LIKE ?";
      args.add('%$q%');
    }
    if (language != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'language = ?';
      args.add(language);
    }
    if (level != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'level = ?';
      args.add(level);
    }
    final rows = await db.query(
      'stories',
      where: where.isEmpty ? null : where,
      whereArgs: args.isEmpty ? null : args,
    );
    List<Story> result = [];
    for (final r in rows) {
      // load sections
      final sectionsRows = await db.query(
        'sections',
        where: 'storyId = ?',
        whereArgs: [r['id']],
      );
      final sections = sectionsRows.map((s) => Section.fromMap(s)).toList();
      // load quiz and questions
      final quizRows = await db.query(
        'quizzes',
        where: 'storyId = ?',
        whereArgs: [r['id']],
      );
      Quiz? quiz;
      if (quizRows.isNotEmpty) {
        final qRow = quizRows.first;
        final questionRows = await db.query(
          'questions',
          where: 'quizId = ?',
          whereArgs: [qRow['id']],
          orderBy: 'orderIndex',
        );
        final questions = questionRows.map((q) => Question.fromMap(q)).toList();
        quiz = Quiz.fromMap(qRow, questions);
      }
      result.add(Story.fromMap(r, sections: sections, quiz: quiz));
    }
    return result;
  }

  // For download, return all story package metadata (sections + quiz) as Story object
  Future<Story?> getStoryById(String id) async {
    final db = await _dbp.database;
    final rows = await db.query('stories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    final sectionsRows = await db.query(
      'sections',
      where: 'storyId = ?',
      whereArgs: [id],
      orderBy: 'orderIndex',
    );
    final sections = sectionsRows.map((s) => Section.fromMap(s)).toList();
    final quizRows = await db.query(
      'quizzes',
      where: 'storyId = ?',
      whereArgs: [id],
    );
    Quiz? quiz;
    if (quizRows.isNotEmpty) {
      final qRow = quizRows.first;
      final questionRows = await db.query(
        'questions',
        where: 'quizId = ?',
        whereArgs: [qRow['id']],
        orderBy: 'orderIndex',
      );
      final questions = questionRows.map((q) => Question.fromMap(q)).toList();
      quiz = Quiz.fromMap(qRow, questions);
    }
    return Story.fromMap(r, sections: sections, quiz: quiz);
  }
}
