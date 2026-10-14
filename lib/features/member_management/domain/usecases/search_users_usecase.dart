import 'package:family_guard/features/member_management/domain/entities/search_user.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class SearchUsersUseCase {
  SearchUsersUseCase(this._repository);

  final MemberManagementRepository _repository;

  Future<List<SearchUser>> call(String keyword) {
    return _repository.searchUsers(keyword);
  }
}
