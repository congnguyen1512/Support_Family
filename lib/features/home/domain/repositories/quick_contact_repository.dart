import 'package:family_guard/features/home/domain/entities/quick_contact.dart';

abstract class QuickContactRepository {
  Future<QuickContact?> getQuickContact();
  Future<QuickContact> saveQuickContact(QuickContact contact);
  Future<void> deleteQuickContact();
}
