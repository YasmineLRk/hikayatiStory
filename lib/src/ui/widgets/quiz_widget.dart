// ui/widgets/quiz_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/quiz.dart';

class QuizWidget extends StatefulWidget {
  final Quiz quiz;
  const QuizWidget({required this.quiz, super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final Map<String, int> _answers = {};
  int _score = 0;
  bool _submitted = false;

  void _select(String qId, int idx) {
    if (_submitted) return;
    setState(() => _answers[qId] = idx);
  }

  void _submit() {
    var s = 0;
    for (final q in widget.quiz.questions) {
      final a = _answers[q.id];
      if (a != null && a == q.correctIndex) s++;
    }
    setState(() {
      _score = s;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quiz.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.quiz.questions.map((q) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.prompt,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: List.generate(q.options.length, (i) {
                      final selected = _answers[q.id] == i;
                      Color? tileColor;
                      if (_submitted) {
                        if (i == q.correctIndex)
                          tileColor = Colors.green[100];
                        else if (selected && i != q.correctIndex)
                          tileColor = Colors.red[100];
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: tileColor,
                        child: RadioListTile<int>(
                          value: i,
                          groupValue: _answers[q.id],
                          onChanged: (v) => _select(q.id, v!),
                          title: Text(q.options[i]),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
            const SizedBox(height: 8),
            if (!_submitted)
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            if (_submitted)
              Text('Score: $_score / ${widget.quiz.questions.length}'),
          ],
        ),
      ),
    );
  }
}
