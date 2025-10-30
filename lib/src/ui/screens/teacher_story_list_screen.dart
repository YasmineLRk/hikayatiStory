import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/story_repository.dart';
import '../../models/story.dart';
import 'story_editor_screen.dart';
import 'story_detail_screen.dart';

class TeacherStoryListScreen extends StatefulWidget {
  final AuthService authService;
  const TeacherStoryListScreen({required this.authService, super.key});

  @override
  State<TeacherStoryListScreen> createState() => _TeacherStoryListScreenState();
}

class _TeacherStoryListScreenState extends State<TeacherStoryListScreen> {
  final StoryRepository _repo = StoryRepository();

  List<Story> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _repo.listStories();
    // teacher should see only their stories
    final mine = all
        .where((s) => s.authorId == widget.authService.currentUser?.id)
        .toList();
    setState(() {
      _stories = mine;
      _loading = false;
    });
  }

  void _create() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => StoryEditorScreen(authService: widget.authService),
          ),
        )
        .then((_) => _load());
  }

  Future<void> _delete(Story s) async {
    // confirm
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete story?'),
        content: Text('Delete "${s.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteStory(s.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Stories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
              IconButton(
                onPressed: () {
                  widget.authService.logout();
                  context.go('/login');
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _stories.isEmpty
                ? const Center(child: Text('No stories yet'))
                : ListView.builder(
                    itemCount: _stories.length,
                    itemBuilder: (_, i) {
                      final s = _stories[i];
                      return Card(
                        child: ListTile(
                          title: Text(s.title),
                          subtitle: Text('${s.language} • ${s.level}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  context.go('/story/${s.id}');

                                  /* Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (_) => StoryEditorScreen(
                                            authService: widget.authService,
                                            existing: s,
                                          ),
                                        ),
                                      )
                                      .then((_) => _load()); */
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(s),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StoryDetailScreen(
                                  authService: widget.authService,
                                  storyId: s.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
