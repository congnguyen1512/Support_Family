import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';

enum CallActionType { phone, video, inApp }

class CallTargetArgs {
  const CallTargetArgs({
    required this.name,
    required this.avatarUrl,
    required this.role,
    this.presenceLabel = 'Trực tuyến',
  });

  final String name;
  final String avatarUrl;
  final MemberRole role;
  final String presenceLabel;

  String get roleLabel {
    switch (role) {
      case MemberRole.child:
        return 'Trẻ em';
      case MemberRole.adult:
        return 'Người Lớn';
      case MemberRole.senior:
        return 'Người Già';
    }
  }
}

class InAppCallArgs {
  const InAppCallArgs({
    required this.name,
    required this.avatarUrl,
    required this.role,
  });

  final String name;
  final String avatarUrl;
  final MemberRole role;

  String get roleLabel {
    switch (role) {
      case MemberRole.child:
        return 'Trẻ em';
      case MemberRole.adult:
        return 'Người Lớn';
      case MemberRole.senior:
        return 'Người Già';
    }
  }
}
