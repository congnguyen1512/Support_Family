import 'dart:async';
import 'dart:collection';

import 'package:family_guard/core/fall_detection/data/sensor_stream_service.dart';
import 'package:family_guard/core/fall_detection/data/tflite_inference_service.dart';
import 'package:family_guard/core/fall_detection/domain/fall_event.dart';
import 'package:flutter/foundation.dart';

class FallDetectionService {
  FallDetectionService._();

  static final FallDetectionService instance = FallDetectionService._();

  final SensorStreamService _sensorStreamService = SensorStreamService();
  final TfliteInferenceService _inferenceService = TfliteInferenceService();
  final Queue<SensorFrame> _windowBuffer = Queue<SensorFrame>();

  final StreamController<FallEvent> _fallEventsController =
      StreamController<FallEvent>.broadcast();
  final StreamController<double> _probabilityController =
      StreamController<double>.broadcast();
  final List<FallEvent> _eventHistory = [];
  static const int _maxHistorySize = 50;

  StreamSubscription<SensorFrame>? _sensorSubscription;

  int _windowSize = 150;
  static const int _inferenceStride = 25;
  static const double _fallThreshold = 0.9;
  static const int _requiredConsecutiveHits = 2;
  static const Duration _eventCooldown = Duration(seconds: 5);

  bool _isInitialized = false;
  bool _isRunning = false;
  bool _isInferencing = false;
  int _sampleCounter = 0;
  int _consecutiveHitCount = 0;
  int _inferenceCount = 0;
  DateTime? _lastEventAt;
  DateTime? _lastInferenceAt;
  String? _lastPipelineError;

  Stream<FallEvent> get fallEvents => _fallEventsController.stream;
  Stream<double> get probabilityStream => _probabilityController.stream;

  bool get isInitialized => _isInitialized;
  bool get isRunning => _isRunning;
  bool get modelReady => _inferenceService.isReady;
  String? get modelLoadError => _inferenceService.lastError;
  int get sensorFrameCount => _sensorStreamService.emittedFrames;
  DateTime? get lastSensorFrameAt => _sensorStreamService.lastFrameAt;
  String? get sensorError => _sensorStreamService.lastErrorMessage;
  int get bufferedSamples => _windowBuffer.length;
  int get requiredWindowSamples => _windowSize;
  int get inferenceCount => _inferenceCount;
  DateTime? get lastInferenceAt => _lastInferenceAt;
  String? get lastPipelineError => _lastPipelineError;
  List<FallEvent> get eventHistory => List.unmodifiable(_eventHistory);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _inferenceService.initialize();
    _windowSize = _inferenceService.expectedTimesteps;
    _isInitialized = true;

    if (_inferenceService.isReady) {
      debugPrint('Fall detection model loaded successfully.');
    } else {
      final error = _inferenceService.lastError;
      if (error == null || error.isEmpty) {
        debugPrint(
          'Fall detection model is not ready. Verify assets/models/fall_multitask_model.tflite and runtime compatibility.',
        );
      } else {
        debugPrint('Fall detection model is not ready: $error');
      }
    }
  }

  Future<void> reloadModel() async {
    final wasRunning = _isRunning;
    if (wasRunning) {
      await stopMonitoring();
    }

    await _inferenceService.dispose();
    _isInitialized = false;
    await initialize();

    if (wasRunning) {
      startMonitoring();
    }
  }

  void startMonitoring() {
    if (_isRunning) return;
    if (!_isInitialized) {
      throw StateError(
        'FallDetectionService must be initialized before startMonitoring().',
      );
    }

    _sensorStreamService.start();
    _sensorSubscription = _sensorStreamService.stream.listen(_onSensorFrame);

    _isRunning = true;
    debugPrint('Fall detection monitoring started.');
  }

  Future<void> stopMonitoring() async {
    if (!_isRunning) return;

    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    await _sensorStreamService.stop();

    _isRunning = false;
    _windowBuffer.clear();
    _sampleCounter = 0;
    _consecutiveHitCount = 0;
    _inferenceCount = 0;
    _lastInferenceAt = null;
    _lastPipelineError = null;
    _isInferencing = false;

    debugPrint('Fall detection monitoring stopped.');
  }

  Future<void> dispose() async {
    await stopMonitoring();
    await _sensorStreamService.dispose();
    await _inferenceService.dispose();
    await _fallEventsController.close();
    await _probabilityController.close();
    _eventHistory.clear();
  }

  Future<void> _onSensorFrame(SensorFrame frame) async {
    _windowBuffer.addLast(frame);
    if (_windowBuffer.length > _windowSize) {
      _windowBuffer.removeFirst();
    }

    _sampleCounter++;
    final shouldInfer =
        _windowBuffer.length == _windowSize &&
        _sampleCounter % _inferenceStride == 0;

    if (!shouldInfer || _isInferencing) return;

    _isInferencing = true;
    try {
      final result = _inferenceService.runInference(
        _windowBuffer.toList(growable: false),
      );
      _inferenceCount++;
      _lastInferenceAt = DateTime.now();
      _lastPipelineError = null;

      _probabilityController.add(result.fallProbability);

      if (result.fallProbability >= _fallThreshold) {
        _consecutiveHitCount++;
      } else {
        _consecutiveHitCount = 0;
      }

      if (_consecutiveHitCount >= _requiredConsecutiveHits) {
        final now = DateTime.now();
        final lastEventAt = _lastEventAt;
        if (lastEventAt == null ||
            now.difference(lastEventAt) >= _eventCooldown) {
          _lastEventAt = now;
          final event = FallEvent(
            detectedAt: now,
            probability: result.fallProbability,
          );
          _fallEventsController.add(event);
          _addToHistory(event);
          debugPrint(
            'Possible fall detected. probability=${result.fallProbability.toStringAsFixed(3)}',
          );
        }
      }
    } catch (error, stackTrace) {
      _lastPipelineError = error.toString();
      debugPrint('Fall inference failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isInferencing = false;
    }
  }

  void _addToHistory(FallEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }
}
