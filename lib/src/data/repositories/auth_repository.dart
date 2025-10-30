import 'package:uuid/uuid.dart';
import '../../models/user.dart';
import '../db_provider.dart';

class AuthRepository {
  final DBProvider _dbp = DBProvider();
  final Uuid _uuid = Uuid();

  Future<User> registerTeacher({
    required String email,
    required String displayName,
    required String passwordHash,
  }) async {
    final db = await _dbp.database;
    final id = _uuid.v4();
    final user = User(
      id: id,
      email: email,
      displayName: displayName,
      role: UserRole.teacher,
      passwordHash: passwordHash,
    );
    await db.insert('users', user.toMap());
    return user;
  }

  Future<User?> login(String email, String passwordHash) async {
    final db = await _dbp.database;
    final res = await db.query(
      'users',
      where: 'email = ? AND passwordHash = ?',
      whereArgs: [email, passwordHash],
    );
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<User?> getUserById(String id) async {
    final db = await _dbp.database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }
}
