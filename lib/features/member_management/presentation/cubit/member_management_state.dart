import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/entities/search_user.dart';

class MemberManagementState {
  const MemberManagementState({
    this.isLoadingMembers = false,
    this.isSearching = false,
    this.isInviting = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.successMessage,
    this.relationships = const <Relationship>[],
    this.searchResults = const <SearchUser>[],
  });

  final bool isLoadingMembers;
  final bool isSearching;
  final bool isInviting;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final String? successMessage;
  final List<Relationship> relationships;
  final List<SearchUser> searchResults;

  MemberManagementState copyWith({
    bool? isLoadingMembers,
    bool? isSearching,
    bool? isInviting,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    String? successMessage,
    List<Relationship>? relationships,
    List<SearchUser>? searchResults,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return MemberManagementState(
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isSearching: isSearching ?? this.isSearching,
      isInviting: isInviting ?? this.isInviting,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      relationships: relationships ?? this.relationships,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
