import 'package:family_guard/features/login/domain/entities/auth_session.dart';

class AuthSessionState {
  const AuthSessionState({
    this.isLoading = false,
    this.errorMessage,
    this.session,
  });

  final bool isLoading;
  final String? errorMessage;
  final AuthSession? session;

  bool get isAuthenticated => session != null;

  AuthSessionState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthSession? session,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthSessionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
    );
  }
}
