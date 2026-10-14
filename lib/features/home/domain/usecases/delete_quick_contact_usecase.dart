import 'package:family_guard/features/home/domain/repositories/quick_contact_repository.dart';

class DeleteQuickContactUseCase {
  const DeleteQuickContactUseCase(this._repository);

  final QuickContactRepository _repository;

  Future<void> call() => _repository.deleteQuickContact();
}
