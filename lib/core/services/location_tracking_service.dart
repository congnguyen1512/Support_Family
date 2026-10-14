import 'dart:async';

import 'package:family_guard/core/network/api_constants.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/update_my_location_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService extends ChangeNotifier {
  LocationTrackingService({
    required UpdateMyLocationUseCase updateMyLocationUseCase,
  }) : _updateMyLocationUseCase = updateMyLocationUseCase;

  final UpdateMyLocationUseCase _updateMyLocationUseCase;

  Timer? _timer;
  bool _isRunning = false;
  bool _isUpdating = false;
  String? _lastErrorMessage;
  UserLocation? _lastLocation;

  bool get isRunning => _isRunning;
  String? get lastErrorMessage => _lastErrorMessage;
  UserLocation? get lastLocation => _lastLocation;

  Future<void> start() async {
    if (_isRunning) {
      await _updateNow();
      return;
    }

    _isRunning = true;
    notifyListeners();

    await _updateNow();

    _timer = Timer.periodic(ApiConstants.locationTrackingInterval, (_) {
      unawaited(_updateNow());
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  Future<void> refreshNow() async {
    await _updateNow();
  }

  Future<void> _updateNow() async {
    if (_isUpdating) {
      return;
    }

    _isUpdating = true;
    try {
      _debugLog('Starting location refresh');
      final position = await _getCurrentPosition();
      _debugLog(
        'Geolocator position'
        ' lat=${position.latitude}'
        ' lng=${position.longitude}'
        ' accuracy=${position.accuracy}'
        ' speed=${position.speed}'
        ' timestamp=${position.timestamp.toIso8601String()}',
      );
      final resolvedAddress = await _reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _debugLog(
        'Reverse geocode'
        ' address=${resolvedAddress?.formattedAddress ?? 'null'}'
        ' street=${resolvedAddress?.street ?? 'null'}'
        ' ward=${resolvedAddress?.ward ?? 'null'}'
        ' district=${resolvedAddress?.district ?? 'null'}'
        ' city=${resolvedAddress?.city ?? 'null'}'
        ' country=${resolvedAddress?.country ?? 'null'}',
      );
      final location = await _updateMyLocationUseCase(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed.isFinite ? position.speed : null,
        address: resolvedAddress?.formattedAddress,
        street: resolvedAddress?.street,
        ward: resolvedAddress?.ward,
        district: resolvedAddress?.district,
        city: resolvedAddress?.city,
        country: resolvedAddress?.country,
        placeName: resolvedAddress?.placeName,
        timestamp: position.timestamp.toIso8601String(),
      );
      _debugLog(
        'Backend saved location'
        ' lat=${location.latitude}'
        ' lng=${location.longitude}'
        ' address=${location.formattedAddress ?? location.address ?? 'null'}'
        ' updatedAt=${location.updatedAt?.toIso8601String() ?? 'null'}',
      );
      _lastLocation = location;
      _lastErrorMessage = null;
      notifyListeners();
    } catch (error) {
      _lastErrorMessage = error.toString();
      _debugLog('Location refresh failed: $error');
      notifyListeners();
    } finally {
      _isUpdating = false;
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dich vu GPS dang tat. Vui long bat vi tri de tiep tuc.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Quyen vi tri bi tu choi. Vui long cap quyen de theo doi vi tri.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyen vi tri bi tu choi vinh vien. Hay mo cai dat de cap quyen.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<_ResolvedAddress?> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }

      final placemark = placemarks.first;
      final street = _resolveStreet(placemark);
      final formattedAddress = _joinAddressParts([
        street,
        placemark.subLocality,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.country,
      ]);

      return _ResolvedAddress(
        street: street,
        ward: _normalize(placemark.subLocality),
        district: _normalize(placemark.subAdministrativeArea),
        city: _normalize(placemark.locality) ?? _normalize(placemark.administrativeArea),
        country: _normalize(placemark.country),
        placeName: _normalize(placemark.name),
        formattedAddress: formattedAddress,
      );
    } catch (_) {
      return null;
    }
  }

  String? _resolveStreet(Placemark placemark) {
    final name = _normalize(placemark.name);
    final houseNumber = _normalize(placemark.subThoroughfare);
    final road = _normalize(placemark.thoroughfare);
    final street = _normalize(placemark.street);

    final exactStreet = _joinAddressParts([houseNumber, road]);
    final candidates = <String?>[name, exactStreet, street].whereType<String>().toList();

    for (final candidate in candidates) {
      if (_containsDigit(candidate)) {
        return candidate;
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  String? _joinAddressParts(List<String?> parts) {
    final values = <String>[];
    for (final part in parts) {
      final value = _normalize(part);
      if (value != null && !values.contains(value)) {
        values.add(value);
      }
    }
    if (values.isEmpty) {
      return null;
    }
    return values.join(', ');
  }

  String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  bool _containsDigit(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  void _debugLog(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[LocationTrackingService] $message');
  }
}

class _ResolvedAddress {
  const _ResolvedAddress({
    required this.formattedAddress,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.country,
    required this.placeName,
  });

  final String? formattedAddress;
  final String? street;
  final String? ward;
  final String? district;
  final String? city;
  final String? country;
  final String? placeName;
}
