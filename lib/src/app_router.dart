import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hikayati/src/models/story.dart';

import 'services/auth_service.dart';

// screens
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/story_detail_screen.dart';
import 'ui/screens/story_editor_screen.dart';
import 'ui/screens/download_package_screen.dart';
import 'ui/screens/teacher_story_list_screen.dart';
import 'ui/screens/student_story_list_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/widgets/bottom_nav.dart';

class AppRouter {
  final AuthService authService;
  late final GoRouter router;

  AppRouter({required this.authService}) {
    router = GoRouter(
      initialLocation: '/student/stories',

      //refreshListenable: GoRouterRefreshStream(authServiceChanges(authService)),
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final user = authService.currentUser;
            return Scaffold(
              appBar: AppBar(
                title: Text("Hikayati App"),
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
              ),
              body: BottomNavShell(userRole: user?.role, child: child),
            );
          },
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  LoginScreen(authService: authService),
            ),
            GoRoute(
              path: '/register',
              builder: (context, state) =>
                  RegisterScreen(authService: authService),
            ),

            // Shell route for authenticated users with bottom nav
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(authService: authService),
            ),
            GoRoute(
              path: '/teacher/stories',
              builder: (context, state) =>
                  TeacherStoryListScreen(authService: authService),
            ),
            GoRoute(
              path: '/student/stories',
              builder: (context, state) =>
                  StudentStoryListScreen(authService: authService),
            ),

            // Detail / Editor / Download screens
            GoRoute(
              path: '/story/:id',
              builder: (context, state) => StoryDetailScreen(
                authService: authService,
                storyId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/editor',
              builder: (context, state) =>
                  StoryEditorScreen(authService: authService),
            ),
            GoRoute(
              path: '/download',
              builder: (context, state) {
                //final id = state.pathParameters['id']!;
                final story = state.extra as Story;
                // Normally you'd load story by id; here placeholder
                return Scaffold(body: DownloadPackageScreen(story: story));
              },
            ),
          ],
        ),
      ],
    );
  }

  // simple notifier so router can refresh when auth changes
  Stream<bool> authServiceChanges(AuthService auth) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield auth.currentUser != null;
    }
  }
}
