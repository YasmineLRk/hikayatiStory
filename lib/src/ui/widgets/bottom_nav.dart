import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../src/models/user.dart';

class BottomNavShell extends StatefulWidget {
  final UserRole? userRole;
  final Widget child;
  const BottomNavShell({
    required this.userRole,
    required this.child,
    super.key,
  });

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.userRole == UserRole.teacher;

    final teacherTabs = [
      {'label': 'All Stories', 'icon': Icons.home, 'route': '/student/stories'},
      {'label': 'My Stories', 'icon': Icons.book, 'route': '/teacher/stories'},
      {'label': 'Create', 'icon': Icons.edit, 'route': '/editor'},
    ];

    final studentTabs = [
      {'label': 'All Stories', 'icon': Icons.book, 'route': '/student/stories'},
      {'label': 'Teacher', 'icon': Icons.person, 'route': '/home'},
    ];

    final tabs = isTeacher ? teacherTabs : studentTabs;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          context.go(tabs[i]['route'] as String);
        },
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,

        items: [
          for (final t in tabs)
            BottomNavigationBarItem(
              icon: Icon(t['icon'] as IconData),
              label: t['label'] as String,
            ),
        ],
      ),
    );
  }
}
