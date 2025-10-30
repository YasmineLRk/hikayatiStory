import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/story_repository.dart';
import '../../models/story.dart';
import '../../models/section.dart';
import '../widgets/quiz_widget.dart';

import 'package:cached_network_image/cached_network_image.dart';

class StoryDetailScreen extends StatefulWidget {
  final AuthService authService;
  final String storyId;
  const StoryDetailScreen({
    required this.authService,
    required this.storyId,
    super.key,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoryRepository _repo = StoryRepository();
  final FlutterTts _tts = FlutterTts();

  Story? _story;
  bool _loading = true;
  int? _readingIndex;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
    _setupTts();
  }

  void _setupTts() {
    _tts.setCompletionHandler(() {
      setState(() {
        _readingIndex = null;
        _isSpeaking = false;
      });
    });
  }

  Future<void> _loadStory() async {
    setState(() => _loading = true);
    final s = await _repo.getStoryById(widget.storyId);
    setState(() {
      _story = s;
      _loading = false;
    });
  }

  Future<void> _speakSection(Section section, int index) async {
    // Stop if already speaking the same section
    if (_isSpeaking && _readingIndex == index) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
        _readingIndex = null;
      });
      return;
    }

    await _tts.stop(); // stop any previous speech
    setState(() {
      _readingIndex = index;
      _isSpeaking = true;
    });

    await _tts.setLanguage(_story?.language ?? 'en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.speak(section.text);
  }

  Future<void> _stopReading() async {
    await _tts.stop();
    setState(() {
      _readingIndex = null;
      _isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    //_tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_story == null) {
      return const Scaffold(body: Center(child: Text('Story not found')));
    }

    final isTeacherOwner =
        widget.authService.currentUser?.id == _story?.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_story!.title),
        actions: [
          if (_isSpeaking)
            IconButton(icon: const Icon(Icons.stop), onPressed: _stopReading),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _story!.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Level: ${_story!.level} • Language: ${_story!.language}'),
            const SizedBox(height: 12),

            //  Highlighted reading sections
            for (int i = 0; i < _story!.sections.length; i++)
              _buildSectionCard(_story!.sections[i], i),

            const SizedBox(height: 12),
            if (_story!.quiz != null) QuizWidget(quiz: _story!.quiz!),

            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    /* Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DownloadPackageScreen(story: _story!),
                      ),
                    ); */
                    context.go('/download', extra: _story);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download package'),
                ),
                const SizedBox(width: 12),
                if (isTeacherOwner)
                  ElevatedButton.icon(
                    onPressed: () {
                      /* Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StoryEditorScreen(
                            authService: widget.authService,
                            existing: _story,
                          ),
                        ),
                      ); */
                      context.go('/editor');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(Section section, int index) {
    final isActive = index == _readingIndex;
    return Card(
      color: isActive ? Colors.yellow[100] : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.heading,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepOrange : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(section.text),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _speakSection(section, index),
                  icon: Icon(
                    _readingIndex == index && _isSpeaking
                        ? Icons.stop
                        : Icons.volume_up,
                  ),
                  label: Text(
                    _readingIndex == index && _isSpeaking
                        ? 'Stop'
                        : 'Read Aloud',
                  ),
                ),
              ],
            ),

            /*  if (section.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.network(
                  section.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ), */
            if (section.imageUrl != null)
              CachedNetworkImage(
                imageUrl: section.imageUrl!,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
