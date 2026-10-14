import 'package:family_guard/features/home/data/datasources/quick_contact_remote_data_source.dart';
import 'package:family_guard/features/home/domain/entities/quick_contact.dart';
import 'package:family_guard/features/home/domain/repositories/quick_contact_repository.dart';

class QuickContactRepositoryImpl implements QuickContactRepository {
  QuickContactRepositoryImpl({required QuickContactRemoteDataSource remote})
      : _remote = remote;

  final QuickContactRemoteDataSource _remote;

  @override
  Future<QuickContact?> getQuickContact() => _remote.getQuickContact();

  @override
  Future<QuickContact> saveQuickContact(QuickContact contact) =>
      _remote.saveQuickContact(contact);

  @override
  Future<void> deleteQuickContact() => _remote.deleteQuickContact();
}
