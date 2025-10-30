import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // <- ADDED import
import '../../models/story.dart';

class DownloadPackageScreen extends StatefulWidget {
  final Story story;
  const DownloadPackageScreen({required this.story, super.key});

  @override
  State<DownloadPackageScreen> createState() => _DownloadPackageScreenState();
}

class _DownloadPackageScreenState extends State<DownloadPackageScreen> {
  bool _downloading = false;
  String? _result;

  Future<void> _exportAsJson() async {
    setState(() {
      _downloading = true;
      _result = null;
    });
    final map = {
      'id': widget.story.id,
      'title': widget.story.title,
      'language': widget.story.language,
      'level': widget.story.level,
      'keywords': widget.story.keywords,
      'sections': widget.story.sections
          .map(
            (s) => {
              'id': s.id,
              'heading': s.heading,
              'text': s.text,
              'imageUrl': s.imageUrl,
            },
          )
          .toList(),
      'quiz': widget.story.quiz == null
          ? null
          : {
              'id': widget.story.quiz!.id,
              'title': widget.story.quiz!.title,
              'questions': widget.story.quiz!.questions
                  .map(
                    (q) => {
                      'id': q.id,
                      'prompt': q.prompt,
                      'options': q.options,
                      'correctIndex': q.correctIndex,
                    },
                  )
                  .toList(),
            },
    };

    final json = const JsonEncoder.withIndent('  ').convert(map);
    try {
      final dir = await getDownloadsDirectory(); // from path_provider
      final file = File('${dir!.path}/${widget.story.id}.json');
      await file.writeAsString(json);
      setState(() {
        _result = 'Package succussfully Exported';
        _downloading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Failed: $e';
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Package')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Package dowloaded successfully"',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _downloading ? null : _exportAsJson,
              icon: const Icon(Icons.file_download),
              label: _downloading
                  ? const Text('Exporting...')
                  : const Text('Export as JSON'),
            ),
            const SizedBox(height: 16),
            if (_result != null) SelectableText(_result!),
          ],
        ),
      ),
    );
  }
}
