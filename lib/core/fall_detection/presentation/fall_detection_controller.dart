import 'dart:async';

import 'package:family_guard/core/fall_detection/data/fall_detection_service.dart';
import 'package:family_guard/core/fall_detection/domain/fall_event.dart';
import 'package:flutter/foundation.dart';

class FallDetectionController extends ValueNotifier<FallEvent?> {
  FallDetectionController._() : super(null);

  static final FallDetectionController instance = FallDetectionController._();

  StreamSubscription<FallEvent>? _subscription;

  bool _isBound = false;

  bool get isBound => _isBound;

  void bind(FallDetectionService service) {
    if (_isBound) return;

    _subscription = service.fallEvents.listen((event) {
      value = event;
    });
    _isBound = true;
  }

  Future<void> unbind() async {
    await _subscription?.cancel();
    _subscription = null;
    _isBound = false;
  }
}
