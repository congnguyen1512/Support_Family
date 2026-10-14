class AuthUser {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String email;

  AuthUser copyWith({String? id, String? email}) {
    return AuthUser(id: id ?? this.id, email: email ?? this.email);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
