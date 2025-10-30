import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/story_repository.dart';

class StudentStoryListScreen extends StatefulWidget {
  final AuthService authService;
  const StudentStoryListScreen({required this.authService, super.key});

  @override
  State<StudentStoryListScreen> createState() => _StudentStoryListScreenState();
}

class _StudentStoryListScreenState extends State<StudentStoryListScreen> {
  final StoryRepository _repo = StoryRepository();
  bool _loading = true;
  List _stories = [];

  @override
  void initState() {
    super.initState();
    _load("");
  }

  Future<void> _load(String filter) async {
    setState(() => _loading = true);
    final list = await _repo.listStories();
    // students see only published stories
    final published = list.where((s) => s.published).toList();
    setState(() {
      _stories = published
          .where((e) => e.title.toLowerCase().contains(filter.toLowerCase()))
          .toList();
      ;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Stories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Search by title'),
                      onChanged: (v) {
                        //_query = v;
                        _load(v);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _stories.isEmpty
                  ? const Center(child: Text('No stories published yet'))
                  : ListView.builder(
                      itemCount: _stories.length,
                      itemBuilder: (_, i) {
                        final s = _stories[i];
                        return Card(
                          child: ListTile(
                            title: Text(s.title),
                            subtitle: Text('${s.language} • ${s.level}'),
                            onTap: () {
                              /* Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StoryDetailScreen(
                                  authService: widget.authService,
                                  storyId: s.id,
                                ),
                              ),
                            ); */
                              context.go('/story/${s.id}');
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
