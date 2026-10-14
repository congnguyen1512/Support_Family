import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/create_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/delete_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/get_safe_zones_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/update_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/presentation/bloc/safe_zone_event.dart';
import 'package:family_guard/features/safe_zone/presentation/bloc/safe_zone_state.dart';
import 'package:flutter/foundation.dart';

class SafeZoneBloc extends ChangeNotifier {
  SafeZoneBloc({
    required GetSafeZonesUseCase getSafeZonesUseCase,
    required CreateSafeZoneUseCase createSafeZoneUseCase,
    required UpdateSafeZoneUseCase updateSafeZoneUseCase,
    required DeleteSafeZoneUseCase deleteSafeZoneUseCase,
  }) : _getSafeZonesUseCase = getSafeZonesUseCase,
       _createSafeZoneUseCase = createSafeZoneUseCase,
       _updateSafeZoneUseCase = updateSafeZoneUseCase,
       _deleteSafeZoneUseCase = deleteSafeZoneUseCase;

  final GetSafeZonesUseCase _getSafeZonesUseCase;
  final CreateSafeZoneUseCase _createSafeZoneUseCase;
  final UpdateSafeZoneUseCase _updateSafeZoneUseCase;
  final DeleteSafeZoneUseCase _deleteSafeZoneUseCase;

  SafeZoneState _state = const SafeZoneState();
  SafeZoneState get state => _state;

  Future<void> dispatch(SafeZoneEvent event) async {
    if (event is LoadSafeZonesEvent) {
      await _load();
      return;
    }
    if (event is CreateSafeZoneEvent) {
      await _create(event);
      return;
    }
    if (event is UpdateSafeZoneEvent) {
      await _update(event);
      return;
    }
    if (event is DeleteSafeZoneEvent) {
      await _delete(event);
    }
  }

  Future<void> _load() async {
    _state = _state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      final zones = await _getSafeZonesUseCase();
      _state = _state.copyWith(isLoading: false, zones: zones, clearError: true);
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    notifyListeners();
  }

  Future<void> _create(CreateSafeZoneEvent event) async {
    _state = _state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      final created = await _createSafeZoneUseCase(event.zone);
      _state = _state.copyWith(
        isSaving: false,
        zones: [created, ..._state.zones],
        successMessage: 'Da tao vung an toan.',
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    notifyListeners();
  }

  Future<void> _update(UpdateSafeZoneEvent event) async {
    _state = _state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      final updated = await _updateSafeZoneUseCase(event.zone);
      _state = _state.copyWith(
        isSaving: false,
        zones: _state.zones.map((zone) => zone.id == updated.id ? updated : zone).toList(),
        successMessage: 'Da cap nhat vung an toan.',
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    notifyListeners();
  }

  Future<void> _delete(DeleteSafeZoneEvent event) async {
    _state = _state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      await _deleteSafeZoneUseCase(event.id);
      _state = _state.copyWith(
        isSaving: false,
        zones: _state.zones.where((zone) => zone.id != event.id).toList(),
        successMessage: 'Da xoa vung an toan.',
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    notifyListeners();
  }
}
