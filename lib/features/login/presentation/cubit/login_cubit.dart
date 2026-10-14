import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/core/utils/validators.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/login/domain/usecases/login_usecase.dart';
import 'package:family_guard/features/login/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';

class LoginCubit extends ChangeNotifier {
  LoginCubit(this._loginUseCase);

  final LoginUseCase _loginUseCase;

  final formKey = GlobalKey<FormState>();
  final emailController =
      TextEditingController(text: 'caregiver@familyguard.test');
  final passwordController =
      TextEditingController(text: 'FamilyGuard@123');

  LoginState _state = const LoginState();
  LoginState get state => _state;

  String? validateEmail(String? value) => Validators.email(value);

  String? validatePassword(String? value) => Validators.password(value);

  void togglePasswordVisibility() {
    _state = _state.copyWith(obscurePassword: !_state.obscurePassword);
    notifyListeners();
  }

  Future<AuthSession?> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return null;
    }

    _state = _state.copyWith(
      isLoading: true,
      clearError: true,
      clearSession: true,
    );
    notifyListeners();

    try {
      final session = await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      _state = _state.copyWith(
        isLoading: false,
        clearError: true,
        session: session,
      );
      notifyListeners();
      return session;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(
          error,
          fallback: 'Dang nhap that bai. Vui long thu lai.',
        ),
      );
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
