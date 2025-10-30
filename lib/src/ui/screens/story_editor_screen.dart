// ui/screens/story_editor_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/story_repository.dart';
import '../../models/story.dart';
import '../../models/section.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';

class StoryEditorScreen extends StatefulWidget {
  final AuthService authService;
  final Story? existing;
  const StoryEditorScreen({
    required this.authService,
    this.existing,
    super.key,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  //final _levelCtl = TextEditingController();
  //final _languageCtl = TextEditingController();
  final _keywordsCtl = TextEditingController();
  final StoryRepository _repo = StoryRepository();
  final _uuid = Uuid();

  List<Section> _sections = [];
  Quiz? _quiz;
  bool _saving = false;
  String _language = 'English';
  String _level = 'Year 1';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleCtl.text = widget.existing!.title;
      _level = widget.existing!.level;
      _language = widget.existing!.language;
      _keywordsCtl.text = widget.existing!.keywords.join(',');
      _sections = List.from(widget.existing!.sections);
      _quiz = widget.existing!.quiz;
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    //_levelCtl.dispose();
    //_languageCtl.dispose();
    _keywordsCtl.dispose();
    super.dispose();
  }

  void _addSection() {
    final id = _uuid.v4();
    setState(() {
      _sections.add(
        Section(id: id, heading: 'Heading', text: 'Text...', imageUrl: null),
      );
    });
  }

  void _removeSection(int idx) {
    setState(() => _sections.removeAt(idx));
  }

  void _editSection(int idx) async {
    final s = _sections[idx];
    final res = await showDialog<Section>(
      context: context,
      builder: (c) {
        final headingCtl = TextEditingController(text: s.heading);
        final textCtl = TextEditingController(text: s.text);

        final imageCtl = TextEditingController(
          text: s.imageUrl ?? "placeholder.png",
        );
        return AlertDialog(
          title: const Text('Edit Section'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: headingCtl,
                  decoration: const InputDecoration(labelText: 'Heading'),
                ),
                TextField(
                  controller: textCtl,
                  decoration: const InputDecoration(labelText: 'Text'),
                  maxLines: 3,
                ),
                TextField(
                  controller: imageCtl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = Section(
                  id: s.id,
                  heading: headingCtl.text,
                  text: textCtl.text,
                  imageUrl: imageCtl.text.isEmpty
                      ? null
                      : "https://raw.githubusercontent.com/YasmineLRk/hikayati/refs/heads/main/assets/images/${imageCtl.text}",
                );
                Navigator.pop(c, updated);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (res != null) {
      setState(() => _sections[idx] = res);
    }
  }

  void _editQuiz() async {
    Quiz? current = _quiz;
    // simple editor: set title and add/remove questions
    final res = await Navigator.of(context).push<Quiz>(
      MaterialPageRoute(builder: (_) => QuizEditorScreen(existing: current)),
    );
    if (res != null) setState(() => _quiz = res);
  }

  Future<void> _save() async {
    if (!widget.authService.isTeacher) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only teachers can save stories')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = widget.existing?.id ?? _uuid.v4();
    final story = Story(
      id: id,
      title: _titleCtl.text.trim(),
      authorId: widget.authService.currentUser!.id,
      language: _language.trim(),
      level: _level.trim(),
      keywords: _keywordsCtl.text.trim().isEmpty
          ? []
          : _keywordsCtl.text.trim().split(','),
      sections: _sections,
      quiz: _quiz,
      published: widget.existing?.published ?? true,
    );

    if (widget.existing == null) {
      await _repo.createStory(story);
    } else {
      await _repo.updateStory(story);
    }

    setState(() => _saving = false);
    //Navigator.of(context).pop();
    context.go("/teacher/stories");
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        widget.existing == null ||
        widget.existing!.authorId == widget.authService.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Create Story' : 'Edit Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Title required' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _language,
                          items: ['English', 'French', 'Arabic']
                              .map(
                                (l) =>
                                    DropdownMenuItem(child: Text(l), value: l),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _language = v!),
                          decoration: InputDecoration(labelText: 'Language'),
                        ),
                      ),
                      /* Expanded(
                        child: TextFormField(
                          controller: _languageCtl,
                          decoration: const InputDecoration(
                            labelText: 'Language (en/fr/ar)',
                          ),
                        ),
                      ), */
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _level,
                          items:
                              [
                                    'KG1',
                                    'KG2',
                                    'Year 1',
                                    'Year 2',
                                    'Year 3',
                                    'Year 4',
                                    'Year 5',
                                    'Year 6',
                                  ]
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l,
                                      child: Text(l),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _level = v!),
                          decoration: InputDecoration(labelText: 'Level'),
                        ),

                        /* TextFormField(
                          controller: _levelCtl,
                          decoration: const InputDecoration(
                            labelText: 'Level (Year1, KG1)',
                          ),
                        ), */
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _keywordsCtl,
                    decoration: const InputDecoration(labelText: 'Keywords'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sections',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addSection,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sections.length,
                    itemBuilder: (_, i) {
                      final s = _sections[i];
                      return Card(
                        child: ListTile(
                          title: Text(s.heading),
                          subtitle: Text(
                            s.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editSection(i),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeSection(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quiz (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _editQuiz,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit quiz'),
                      ),
                    ],
                  ),
                  if (_quiz != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quiz: ${_quiz!.title}'),
                          Text('Questions: ${_quiz!.questions.length}'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Save story'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// small quiz editor screen used above
class QuizEditorScreen extends StatefulWidget {
  final Quiz? existing;
  const QuizEditorScreen({this.existing, super.key});

  @override
  State<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends State<QuizEditorScreen> {
  final _titleCtl = TextEditingController();
  final _uuid = Uuid();
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleCtl.text = widget.existing!.title;
      _questions = List.from(widget.existing!.questions);
    }
  }

  void _addQuestion() {
    final id = _uuid.v4();
    final q = Question(
      id: id,
      prompt: 'New question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 0,
    );
    setState(() => _questions.add(q));
  }

  void _editQuestion(int idx) async {
    final q = _questions[idx];
    final res = await showDialog<Question>(
      context: context,
      builder: (c) {
        final promptCtl = TextEditingController(text: q.prompt);
        final optCtrls = List.generate(
          4,
          (i) => TextEditingController(
            text: q.options.length > i ? q.options[i] : '',
          ),
        );
        int correct = q.correctIndex;
        return StatefulBuilder(
          builder: (c2, setState2) {
            return AlertDialog(
              title: const Text('Edit Question'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: promptCtl,
                      decoration: const InputDecoration(labelText: 'Prompt'),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < 4; i++)
                      TextField(
                        controller: optCtrls[i],
                        decoration: InputDecoration(
                          labelText: 'Option ${i + 1}',
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Correct:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: correct,
                          items: List.generate(
                            4,
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text('Option ${i + 1}'),
                            ),
                          ),
                          onChanged: (v) => setState2(() => correct = v ?? 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final opts = optCtrls.map((e) => e.text).toList();
                    final updated = Question(
                      id: q.id,
                      prompt: promptCtl.text,
                      options: opts,
                      correctIndex: correct,
                    );
                    Navigator.pop(c, updated);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (res != null) setState(() => _questions[idx] = res);
  }

  void _removeQuestion(int idx) {
    setState(() => _questions.removeAt(idx));
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Editor')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Quiz title'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (_, i) {
                  final q = _questions[i];
                  return Card(
                    child: ListTile(
                      title: Text(q.prompt),
                      subtitle: Text('Options: ${q.options.length}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editQuestion(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeQuestion(i),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final id = widget.existing?.id ?? _uuid.v4();
                final quiz = Quiz(
                  id: id,
                  title: _titleCtl.text.isEmpty ? 'Quiz' : _titleCtl.text,
                  questions: _questions,
                );
                Navigator.pop(context, quiz);
              },
              child: const Text('Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
