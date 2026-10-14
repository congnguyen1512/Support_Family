import 'dart:async';

import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/usecases/get_relationships_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/create_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/delete_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/get_safe_zones_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/update_safe_zone_usecase.dart';
import 'package:flutter/material.dart';

class SafeZoneService extends ChangeNotifier {
  SafeZoneService({
    required GetSafeZonesUseCase getSafeZonesUseCase,
    required CreateSafeZoneUseCase createSafeZoneUseCase,
    required UpdateSafeZoneUseCase updateSafeZoneUseCase,
    required DeleteSafeZoneUseCase deleteSafeZoneUseCase,
    required GetRelationshipsUseCase getRelationshipsUseCase,
  }) : _getSafeZonesUseCase = getSafeZonesUseCase,
       _createSafeZoneUseCase = createSafeZoneUseCase,
       _updateSafeZoneUseCase = updateSafeZoneUseCase,
       _deleteSafeZoneUseCase = deleteSafeZoneUseCase,
       _getRelationshipsUseCase = getRelationshipsUseCase;

  final GetSafeZonesUseCase _getSafeZonesUseCase;
  final CreateSafeZoneUseCase _createSafeZoneUseCase;
  final UpdateSafeZoneUseCase _updateSafeZoneUseCase;
  final DeleteSafeZoneUseCase _deleteSafeZoneUseCase;
  final GetRelationshipsUseCase _getRelationshipsUseCase;

  final List<SafeZone> _zones = [];
  final List<SafeZoneMember> _members = [];

  bool _initializing = false;
  bool _initialized = false;
  String? _lastErrorMessage;

  List<SafeZone> get zones => List.unmodifiable(_zones);
  List<SafeZoneMember> get members => List.unmodifiable(_members);
  String? get lastErrorMessage => _lastErrorMessage;

  Future<void> initialize({bool force = false}) async {
    if (_initializing) {
      return;
    }
    if (_initialized && !force) {
      return;
    }

    _initializing = true;
    try {
      await refresh();
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _getRelationshipsUseCase(),
        _getSafeZonesUseCase(),
      ]);
      final relationships = results[0] as List<Relationship>;
      final safeZones = results[1] as List<SafeZone>;

      _zones
        ..clear()
        ..addAll(safeZones);

      _members
        ..clear()
        ..addAll(_buildMembers(relationships, safeZones));

      _lastErrorMessage = null;
      notifyListeners();
    } catch (error) {
      _lastErrorMessage = error.toString();
      notifyListeners();
    }
  }

  SafeZone? getZone(String id) {
    final idx = _zones.indexWhere((z) => z.id == id);
    return idx >= 0 ? _zones[idx] : null;
  }

  List<SafeZone> getZonesForMember(String memberId) {
    return _zones.where((z) => z.recipientIds.contains(memberId)).toList();
  }

  Future<SafeZone?> addZone(SafeZone zone) async {
    try {
      final created = await _createSafeZoneUseCase(_normalizeZone(zone));
      _zones.insert(0, created);
      _syncZoneIdsOnMembers();
      _lastErrorMessage = null;
      notifyListeners();
      return created;
    } catch (error) {
      _lastErrorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<SafeZone?> updateZone(SafeZone zone) async {
    try {
      final updated = await _updateSafeZoneUseCase(_normalizeZone(zone));
      final idx = _zones.indexWhere((z) => z.id == updated.id);
      if (idx >= 0) {
        _zones[idx] = updated;
      }
      _syncZoneIdsOnMembers();
      _lastErrorMessage = null;
      notifyListeners();
      return updated;
    } catch (error) {
      _lastErrorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> removeZone(String id) async {
    try {
      await _deleteSafeZoneUseCase(id);
      _zones.removeWhere((z) => z.id == id);
      _syncZoneIdsOnMembers();
      _lastErrorMessage = null;
      notifyListeners();
    } catch (error) {
      _lastErrorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleZone(String id) async {
    final idx = _zones.indexWhere((z) => z.id == id);
    if (idx < 0) {
      return;
    }

    final current = _zones[idx];
    final optimistic = current.copyWith(isActive: !current.isActive);
    _zones[idx] = optimistic;
    notifyListeners();

    final updated = await updateZone(optimistic);
    if (updated == null) {
      _zones[idx] = current;
      notifyListeners();
    }
  }

  SafeZoneMember? getMember(String id) {
    final idx = _members.indexWhere((m) => m.id == id);
    return idx >= 0 ? _members[idx] : null;
  }

  String nextZoneId() => 'pending_${DateTime.now().millisecondsSinceEpoch}';

  void reset() {
    _zones.clear();
    _members.clear();
    _initialized = false;
    _lastErrorMessage = null;
    notifyListeners();
  }

  List<SafeZoneMember> _buildMembers(
    List<Relationship> relationships,
    List<SafeZone> safeZones,
  ) {
    return relationships
        .where((relationship) => relationship.processing == 'xacnhan')
        .map((relationship) {
          final user = relationship.relationUser;
          final role = user?.role?.trim() ?? '';
          final age = _calculateAge(user?.birthday);
          final ageGroup = _resolveAgeGroup(role, age);
          final uid = relationship.relationId;
          final zoneIds = safeZones
              .where((zone) => zone.recipientIds.contains(uid))
              .map((zone) => zone.id)
              .toList();

          return SafeZoneMember(
            id: uid,
            name: _resolveName(user?.name, user?.email),
            role: role,
            ageGroup: ageGroup,
            badgeColor: _badgeColor(ageGroup).withValues(alpha: 0.12),
            badgeBorderColor: _badgeColor(ageGroup).withValues(alpha: 0.25),
            badgeTextColor: _badgeColor(ageGroup),
            avatarUrl: user?.avata ?? '',
            isOnline: true,
            zoneIds: zoneIds,
          );
        })
        .toList();
  }

  void _syncZoneIdsOnMembers() {
    for (var index = 0; index < _members.length; index++) {
      final member = _members[index];
      _members[index] = member.copyWith(
        zoneIds: _zones
            .where((zone) => zone.recipientIds.contains(member.id))
            .map((zone) => zone.id)
            .toList(),
      );
    }
  }

  SafeZone _normalizeZone(SafeZone zone) {
    final targetUid = zone.targetUid ??
        (zone.recipientIds.isNotEmpty ? zone.recipientIds.first : null);

    return zone.copyWith(
      targetUid: targetUid,
      recipientIds: targetUid == null ? const [] : [targetUid],
      name: zone.name.trim().isEmpty ? 'Vung an toan' : zone.name.trim(),
    );
  }

  String _resolveName(String? name, String? email) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }
    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }
    return 'Thanh vien';
  }

  int? _calculateAge(String? birthday) {
    if (birthday == null || birthday.trim().isEmpty) {
      return null;
    }
    final birthDate = DateTime.tryParse(birthday);
    if (birthDate == null) {
      return null;
    }
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _resolveAgeGroup(String role, int? age) {
    if (role == 'nguoichamsoc') {
      return 'NGUOI CHAM SOC';
    }
    if (age != null && age < 16) {
      return 'TRE EM';
    }
    if (age != null && age >= 60) {
      return '60+ TUOI';
    }
    return 'NGUOI DUOC CHAM SOC';
  }

  Color _badgeColor(String ageGroup) {
    final normalized = ageGroup.toLowerCase();
    if (normalized.contains('tre')) {
      return const Color(0xFF2563EB);
    }
    if (normalized.contains('60')) {
      return const Color(0xFFFF6B00);
    }
    return const Color(0xFF1EA5FC);
  }
}

class SafeZoneProvider extends InheritedNotifier<SafeZoneService> {
  const SafeZoneProvider({
    super.key,
    required SafeZoneService service,
    required super.child,
  }) : super(notifier: service);

  static SafeZoneService? maybeOf(BuildContext context) {
    final scoped =
        context.dependOnInheritedWidgetOfExactType<SafeZoneProvider>()?.notifier;
    if (scoped != null) {
      return scoped;
    }

    if (!AppDependencies.instance.isInitializedForSafeZoneFallback) {
      return null;
    }

    final fallback = AppDependencies.instance.safeZoneService;
    unawaited(fallback.initialize());
    return fallback;
  }

  static SafeZoneService of(BuildContext context) {
    final service = maybeOf(context);
    if (service == null) {
      throw FlutterError('SafeZoneProvider khong ton tai trong widget tree.');
    }
    return service;
  }

  static SafeZoneService read(BuildContext context) {
    final service =
        context.getInheritedWidgetOfExactType<SafeZoneProvider>()?.notifier ??
        (AppDependencies.instance.isInitializedForSafeZoneFallback
            ? AppDependencies.instance.safeZoneService
            : null);
    if (service == null) {
      throw FlutterError('SafeZoneProvider khong ton tai trong widget tree.');
    }
    unawaited(service.initialize());
    return service;
  }
}
