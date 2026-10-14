import 'package:family_guard/features/login/domain/entities/auth_session.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
    this.session,
  });

  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final AuthSession? session;

  LoginState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
    AuthSession? session,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
    );
  }
}
