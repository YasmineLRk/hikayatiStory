// lib/main.dart
import 'package:flutter/material.dart';
import 'src/app_router.dart';
import 'src/services/auth_service.dart';
import 'src/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepo = AuthRepository();
  final authService = AuthService(repo: authRepo);
  final appRouter = AppRouter(authService: authService);
  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({required this.appRouter, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hikayati',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerConfig: appRouter.router,
    );
  }
}
