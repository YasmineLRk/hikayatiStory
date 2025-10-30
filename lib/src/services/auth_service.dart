import '../data/repositories/auth_repository.dart';
import '../models/user.dart';

class AuthService {
  final AuthRepository repo;
  User? _currentUser;

  AuthService({required this.repo});

  User? get currentUser => _currentUser;

  // Simple hash placeholder for demo (DO NOT use in production)
  String _hash(String password) =>
      password; // replace with real hashing for production

  Future<User?> login(String email, String password) async {
    final user = await repo.login(email, _hash(password));
    _currentUser = user;
    return user;
  }

  Future<User> registerTeacher(
    String email,
    String displayName,
    String password,
  ) async {
    final user = await repo.registerTeacher(
      email: email,
      displayName: displayName,
      passwordHash: _hash(password),
    );
    _currentUser = user;
    return user;
  }

  void logout() {
    _currentUser = null;
  }

  bool get isTeacher => _currentUser?.role == UserRole.teacher;
}
