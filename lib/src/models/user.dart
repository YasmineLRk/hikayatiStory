// models/user.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';

enum UserRole { teacher, student }

class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String
  passwordHash; // for local demo only; in real app use secure storage

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': describeEnum(role),
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> m) {
    return User(
      id: m['id'] as String,
      email: m['email'] as String,
      displayName: m['displayName'] as String,
      role: m['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
      passwordHash: m['passwordHash'] as String,
    );
  }
}
