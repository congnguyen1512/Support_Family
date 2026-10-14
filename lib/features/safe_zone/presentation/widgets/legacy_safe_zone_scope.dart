import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';

class LegacySafeZoneScope extends StatelessWidget {
  const LegacySafeZoneScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final service = AppDependencies.instance.safeZoneService;
    service.initialize();
    return SafeZoneProvider(
      service: service,
      child: child,
    );
  }
}
