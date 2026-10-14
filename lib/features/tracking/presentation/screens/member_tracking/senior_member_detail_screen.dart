import 'package:family_guard/features/tracking/presentation/screens/member_tracking/adult_member_detail_screen.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';

class SeniorMemberDetailScreen extends StatelessWidget {
  const SeniorMemberDetailScreen({super.key, required this.args});

  final MemberTrackingArgs args;

  static MemberTrackingArgs fromRoute(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    return routeArgs is MemberTrackingArgs
        ? routeArgs
        : const MemberTrackingArgs.seniorFallback();
  }

  @override
  Widget build(BuildContext context) {
    return AdultMemberDetailScreen(args: args);
  }
}
