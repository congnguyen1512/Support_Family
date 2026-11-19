import 'package:family_guard/features/home/data/datasources/quick_contact_local_data_source.dart';
import 'package:family_guard/features/home/data/datasources/quick_contact_remote_data_source.dart';
import 'package:family_guard/features/home/domain/entities/quick_contact.dart';
import 'package:family_guard/features/home/domain/repositories/quick_contact_repository.dart';

class QuickContactRepositoryImpl implements QuickContactRepository {
  QuickContactRepositoryImpl({
    required QuickContactRemoteDataSource remote,
    QuickContactLocalDataSource? local,
  })  : _remote = remote,
        _local = local ?? QuickContactLocalDataSourceImpl();

  final QuickContactRemoteDataSource _remote;
  final QuickContactLocalDataSource _local;

  @override
  Future<QuickContact?> getQuickContact() async {
    try {
      final remoteContact = await _remote.getQuickContact();
      if (remoteContact != null) {
        await _local.saveQuickContact(remoteContact);
        return remoteContact;
      }
    } catch (_) {
      // Remote call failed, fallback to local storage
    }
    return _local.getQuickContact();
  }

  @override
  Future<QuickContact> saveQuickContact(QuickContact contact) async {
    await _local.saveQuickContact(contact);
    try {
      final saved = await _remote.saveQuickContact(contact);
      await _local.saveQuickContact(saved);
      return saved;
    } catch (_) {
      return contact;
    }
  }

  @override
  Future<void> deleteQuickContact() async {
    await _local.deleteQuickContact();
    try {
      await _remote.deleteQuickContact();
    } catch (_) {}
  }
}
