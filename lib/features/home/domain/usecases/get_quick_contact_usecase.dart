import 'package:family_guard/features/home/domain/entities/quick_contact.dart';
import 'package:family_guard/features/home/domain/repositories/quick_contact_repository.dart';

class GetQuickContactUseCase {
  const GetQuickContactUseCase(this._repository);

  final QuickContactRepository _repository;

  Future<QuickContact?> call() => _repository.getQuickContact();
}
