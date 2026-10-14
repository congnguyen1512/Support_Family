import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/login/domain/usecases/get_saved_session_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/load_current_session_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/logout_usecase.dart';
import 'package:family_guard/features/login/presentation/cubit/auth_session_state.dart';
import 'package:flutter/foundation.dart';

class AuthSessionCubit extends ChangeNotifier {
  AuthSessionCubit({
    required LoadCurrentSessionUseCase loadCurrentSessionUseCase,
    required GetSavedSessionUseCase getSavedSessionUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loadCurrentSessionUseCase = loadCurrentSessionUseCase,
       _getSavedSessionUseCase = getSavedSessionUseCase,
       _logoutUseCase = logoutUseCase;

  final LoadCurrentSessionUseCase _loadCurrentSessionUseCase;
  final GetSavedSessionUseCase _getSavedSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthSessionState _state = const AuthSessionState();
  AuthSessionState get state => _state;

  Future<AuthSession?> loadSavedSession() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final session = await _getSavedSessionUseCase();
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
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
      return null;
    }
  }

  Future<AuthSession?> loadCurrentSession() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final session = await _loadCurrentSessionUseCase();
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
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _logoutUseCase();
      _state = _state.copyWith(
        isLoading: false,
        clearError: true,
        clearSession: true,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
    }
  }
}
