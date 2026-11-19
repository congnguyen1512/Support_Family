import 'package:family_guard/core/storage/session_storage.dart';
import 'package:family_guard/features/home/domain/entities/quick_contact.dart';

abstract class QuickContactLocalDataSource {
  Future<QuickContact?> getQuickContact();
  Future<void> saveQuickContact(QuickContact contact);
  Future<void> deleteQuickContact();
}

class QuickContactLocalDataSourceImpl implements QuickContactLocalDataSource {
  QuickContactLocalDataSourceImpl({SessionStorage? storage})
      : _storage = storage ??
            SessionStorage(fileName: 'family_guard_quick_contact.json');

  final SessionStorage _storage;

  @override
  Future<QuickContact?> getQuickContact() async {
    try {
      final json = await _storage.readJson();
      if (json == null || json.isEmpty) {
        return null;
      }
      return QuickContact.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveQuickContact(QuickContact contact) async {
    try {
      await _storage.writeJson(contact.toJson());
    } catch (_) {}
  }

  @override
  Future<void> deleteQuickContact() async {
    try {
      await _storage.clear();
    } catch (_) {}
  }
}
