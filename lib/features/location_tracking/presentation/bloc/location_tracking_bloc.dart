import 'dart:async';

import 'package:family_guard/core/network/api_constants.dart';
import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/get_family_locations_usecase.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/get_my_location_usecase.dart';
import 'package:family_guard/features/location_tracking/presentation/bloc/location_tracking_event.dart';
import 'package:family_guard/features/location_tracking/presentation/bloc/location_tracking_state.dart';
import 'package:flutter/foundation.dart';

class LocationTrackingBloc extends ChangeNotifier {
  LocationTrackingBloc({
    required GetMyLocationUseCase getMyLocationUseCase,
    required GetFamilyLocationsUseCase getFamilyLocationsUseCase,
  }) : _getMyLocationUseCase = getMyLocationUseCase,
       _getFamilyLocationsUseCase = getFamilyLocationsUseCase;

  final GetMyLocationUseCase _getMyLocationUseCase;
  final GetFamilyLocationsUseCase _getFamilyLocationsUseCase;

  Timer? _familyPollingTimer;
  bool _disposed = false;

  LocationTrackingState _state = const LocationTrackingState();
  LocationTrackingState get state => _state;

  Future<void> dispatch(LocationTrackingEvent event) async {
    if (event is LoadMyLocationEvent) {
      await _loadMyLocation();
      return;
    }
    if (event is LoadFamilyLocationsEvent) {
      await _loadFamilyLocations(showLoader: event.showLoader);
      return;
    }
    if (event is StartFamilyLocationPollingEvent) {
      await _startFamilyPolling();
      return;
    }
    if (event is StopFamilyLocationPollingEvent) {
      _stopFamilyPolling();
    }
  }

  Future<void> _loadMyLocation() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    _safeNotify();

    try {
      final myLocation = await _getMyLocationUseCase();
      _state = _state.copyWith(
        isLoading: false,
        myLocation: myLocation,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    _safeNotify();
  }

  Future<void> _loadFamilyLocations({bool showLoader = true}) async {
    if (showLoader) {
      _state = _state.copyWith(isLoading: true, clearError: true);
      _safeNotify();
    }

    try {
      final familyLocations = await _getFamilyLocationsUseCase();
      _state = _state.copyWith(
        isLoading: false,
        familyLocations: familyLocations,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
    }

    _safeNotify();
  }

  Future<void> _startFamilyPolling() async {
    _familyPollingTimer ??= Timer.periodic(
      ApiConstants.locationTrackingInterval,
      (_) async {
        await _loadMyLocationSilently();
        await _loadFamilyLocations(showLoader: false);
      },
    );

    _state = _state.copyWith(isPollingFamily: true, clearError: true);
    _safeNotify();
    await _loadMyLocationSilently();
    await _loadFamilyLocations();
  }

  Future<void> _loadMyLocationSilently() async {
    try {
      final myLocation = await _getMyLocationUseCase();
      _state = _state.copyWith(myLocation: myLocation, clearError: true);
      _safeNotify();
    } catch (_) {
      // Keep family polling alive even if current-user location is unavailable.
    }
  }

  void _stopFamilyPolling() {
    _familyPollingTimer?.cancel();
    _familyPollingTimer = null;
    _state = _state.copyWith(isPollingFamily: false, clearError: true);
    _safeNotify();
  }

  void _safeNotify() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _familyPollingTimer?.cancel();
    _familyPollingTimer = null;
    super.dispose();
  }
}
