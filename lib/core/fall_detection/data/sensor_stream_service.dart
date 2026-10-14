import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class SensorFrame {
  const SensorFrame({
    required this.timestamp,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
  });

  final DateTime timestamp;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;
}

class SensorStreamService {
  SensorStreamService({this.sampleRateHz = 50})
    : _minimumEmitInterval = Duration(
        microseconds: (1000000 / sampleRateHz).round(),
      );

  final int sampleRateHz;
  final Duration _minimumEmitInterval;

  final StreamController<SensorFrame> _controller =
      StreamController<SensorFrame>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  AccelerometerEvent? _latestAccelerometer;
  GyroscopeEvent? _latestGyroscope;
  DateTime? _lastEmitAt;
  DateTime? _lastFrameAt;
  Object? _lastError;
  int _emittedFrames = 0;

  Stream<SensorFrame> get stream => _controller.stream;
  DateTime? get lastFrameAt => _lastFrameAt;
  int get emittedFrames => _emittedFrames;
  String? get lastErrorMessage => _lastError?.toString();

  bool get isRunning =>
      _accelerometerSubscription != null && _gyroscopeSubscription != null;

  void start() {
    if (isRunning) return;

    _lastError = null;
    _emittedFrames = 0;
    _lastFrameAt = null;

    _accelerometerSubscription =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen(
          (event) {
            _latestAccelerometer = event;
            _emitIfReady();
          },
          onError: (error) {
            _lastError = error;
          },
        );

    _gyroscopeSubscription =
        gyroscopeEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen(
          (event) {
            _latestGyroscope = event;
            _emitIfReady();
          },
          onError: (error) {
            _lastError = error;
          },
        );
  }

  Future<void> stop() async {
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _latestAccelerometer = null;
    _latestGyroscope = null;
    _lastEmitAt = null;
    _lastFrameAt = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  void _emitIfReady() {
    final accelerometer = _latestAccelerometer;
    final gyroscope = _latestGyroscope;

    if (accelerometer == null || gyroscope == null) return;

    final now = DateTime.now();
    final lastEmitAt = _lastEmitAt;
    if (lastEmitAt != null &&
        now.difference(lastEmitAt) < _minimumEmitInterval) {
      return;
    }

    _lastEmitAt = now;
    _lastFrameAt = now;
    _emittedFrames++;
    _controller.add(
      SensorFrame(
        timestamp: now,
        ax: accelerometer.x,
        ay: accelerometer.y,
        az: accelerometer.z,
        gx: gyroscope.x,
        gy: gyroscope.y,
        gz: gyroscope.z,
      ),
    );
  }
}
