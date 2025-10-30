import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hikayati/src/models/user.dart';
import '../../services/auth_service.dart';
import 'teacher_story_list_screen.dart';
import 'student_story_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;
  const HomeScreen({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikayati'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              context.go('/login');
              /* Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(authService: authService),
                ),
              ); */
            },
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                children: [
                  const Text('No user — please login'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go("/login"),
                    child: const Text("Login"),
                  ),
                ],
              ),
            )
          : user.role == UserRole.teacher
          ? TeacherStoryListScreen(authService: authService)
          : StudentStoryListScreen(authService: authService),
    );
  }
}
