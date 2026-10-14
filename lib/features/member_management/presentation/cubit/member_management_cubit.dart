import 'dart:async';

import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/core/realtime/supabase_realtime_client.dart';
import 'package:family_guard/features/member_management/domain/entities/relation_direction_helper.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/entities/search_user.dart';
import 'package:family_guard/features/member_management/domain/usecases/delete_relationship_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/get_relationships_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/invite_relationship_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/search_users_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/update_relationship_usecase.dart';
import 'package:family_guard/features/member_management/presentation/cubit/member_management_state.dart';
import 'package:flutter/foundation.dart';

class MemberManagementCubit extends ChangeNotifier {
  MemberManagementCubit({
    required GetRelationshipsUseCase getRelationshipsUseCase,
    required SearchUsersUseCase searchUsersUseCase,
    required InviteRelationshipUseCase inviteRelationshipUseCase,
    required UpdateRelationshipUseCase updateRelationshipUseCase,
    required DeleteRelationshipUseCase deleteRelationshipUseCase,
    required SupabaseRealtimeClient realtimeClient,
  }) : _getRelationshipsUseCase = getRelationshipsUseCase,
       _searchUsersUseCase = searchUsersUseCase,
       _inviteRelationshipUseCase = inviteRelationshipUseCase,
       _updateRelationshipUseCase = updateRelationshipUseCase,
       _deleteRelationshipUseCase = deleteRelationshipUseCase,
       _realtimeClient = realtimeClient;

  final GetRelationshipsUseCase _getRelationshipsUseCase;
  final SearchUsersUseCase _searchUsersUseCase;
  final InviteRelationshipUseCase _inviteRelationshipUseCase;
  final UpdateRelationshipUseCase _updateRelationshipUseCase;
  final DeleteRelationshipUseCase _deleteRelationshipUseCase;
  final SupabaseRealtimeClient _realtimeClient;

  RealtimeWatchSubscription? _realtimeSubscription;
  Timer? _realtimeRefreshDebounce;
  Timer? _pollingTimer;
  bool _startingRealtime = false;
  bool _isDisposed = false;

  MemberManagementState _state = const MemberManagementState();
  MemberManagementState get state => _state;

  void _safeNotify() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  Future<List<Relationship>> loadMemberList({bool showLoader = true}) async {
    if (showLoader || _state.relationships.isEmpty) {
      _state = _state.copyWith(
        isLoadingMembers: true,
        clearError: true,
        clearSuccess: true,
      );
      _safeNotify();
    }

    try {
      final relationships = await _getRelationshipsUseCase();
      _state = _state.copyWith(
        isLoadingMembers: false,
        clearError: true,
        relationships: relationships,
      );
      _safeNotify();
      return relationships;
    } catch (error) {
      _state = _state.copyWith(
        isLoadingMembers: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return _state.relationships;
    }
  }

  Future<void> startRealtime() async {
    _pollingTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      loadMemberList(showLoader: false);
    });

    if (!_startingRealtime && _realtimeSubscription == null) {
      _startingRealtime = true;
      try {
        _realtimeSubscription = await _realtimeClient.watchRelationships(
          _scheduleRealtimeRefresh,
        );
      } finally {
        _startingRealtime = false;
      }
    }
  }

  Future<void> stopRealtime() async {
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  void _scheduleRealtimeRefresh() {
    if (_isDisposed) {
      return;
    }
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_isDisposed) {
        return;
      }
      loadMemberList(showLoader: false);
    });
  }

  Future<List<SearchUser>> searchMembers(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      _state = _state.copyWith(searchResults: const <SearchUser>[]);
      _safeNotify();
      return const <SearchUser>[];
    }

    _state = _state.copyWith(
      isSearching: true,
      clearError: true,
      clearSuccess: true,
    );
    _safeNotify();

    try {
      final results = await _searchUsersUseCase(trimmed);
      _state = _state.copyWith(
        isSearching: false,
        clearError: true,
        searchResults: results,
      );
      _safeNotify();
      return results;
    } catch (error) {
      _state = _state.copyWith(
        isSearching: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return _state.searchResults;
    }
  }

  void clearSearchResults() {
    _state = _state.copyWith(searchResults: const <SearchUser>[]);
    _safeNotify();
  }

  Future<Relationship?> inviteMember({
    required String targetUid,
    required String relationType,
    String? reverseRelationType,
  }) async {
    _state = _state.copyWith(
      isInviting: true,
      clearError: true,
      clearSuccess: true,
    );
    _safeNotify();

    try {
      final created = await _inviteRelationshipUseCase(
        targetUid: targetUid,
        relationType: relationType,
        reverseRelationType:
            reverseRelationType ??
            RelationDirectionHelper.resolveReverseRelation(relationType),
      );

      _state = _state.copyWith(
        isInviting: false,
        clearError: true,
        successMessage: 'Gửi lời mời thành công.',
        relationships: [created, ..._state.relationships],
        searchResults: _state.searchResults
            .where((item) => item.uid != targetUid)
            .toList(),
      );
      _safeNotify();
      return created;
    } catch (error) {
      _state = _state.copyWith(
        isInviting: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return null;
    }
  }

  Future<Relationship?> updateRelationType({
    required int relationshipId,
    required String relationType,
    String? reverseRelationType,
  }) async {
    _state = _state.copyWith(
      isUpdating: true,
      clearError: true,
      clearSuccess: true,
    );
    _safeNotify();

    try {
      final updated = await _updateRelationshipUseCase(
        id: relationshipId,
        relationType: relationType,
        reverseRelationType:
            reverseRelationType ??
            RelationDirectionHelper.resolveReverseRelation(relationType),
      );

      _state = _state.copyWith(
        isUpdating: false,
        clearError: true,
        successMessage: 'Cập nhật quan hệ thành công.',
        relationships: _state.relationships
            .map((item) => item.id == relationshipId ? updated : item)
            .toList(),
      );
      _safeNotify();
      return updated;
    } catch (error) {
      _state = _state.copyWith(
        isUpdating: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return null;
    }
  }

  Future<Relationship?> deleteMember(int relationshipId) async {
    _state = _state.copyWith(
      isDeleting: true,
      clearError: true,
      clearSuccess: true,
    );
    _safeNotify();

    try {
      final deleted = await _deleteRelationshipUseCase(relationshipId);
      _state = _state.copyWith(
        isDeleting: false,
        clearError: true,
        successMessage: 'Xóa thành viên thành công.',
        relationships: _state.relationships
            .where((item) => item.id != relationshipId)
            .toList(),
      );
      _safeNotify();
      return deleted;
    } catch (error) {
      _state = _state.copyWith(
        isDeleting: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _realtimeRefreshDebounce?.cancel();
    _pollingTimer?.cancel();
    final subscription = _realtimeSubscription;
    _realtimeSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
