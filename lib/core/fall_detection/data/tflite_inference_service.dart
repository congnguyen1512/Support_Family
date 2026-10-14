import 'dart:math' as math;

import 'package:family_guard/core/fall_detection/data/sensor_stream_service.dart';
import 'package:family_guard/core/fall_detection/domain/fall_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteInferenceService {
  static const String defaultModelAssetPath =
      'assets/models/fall_multitask_model.tflite';

  Interpreter? _interpreter;
  String? _lastError;
  bool _hasValidTfliteSignature = false;
  int _expectedTimesteps = 150;
  int _expectedFeatureCount = 6;

  bool get isReady => _interpreter != null;
  String? get lastError => _lastError;
  bool get hasValidTfliteSignature => _hasValidTfliteSignature;
  int get expectedTimesteps => _expectedTimesteps;
  int get expectedFeatureCount => _expectedFeatureCount;

  Future<void> initialize({
    String modelAssetPath = defaultModelAssetPath,
  }) async {
    if (_interpreter != null) return;

    _lastError = null;
    _hasValidTfliteSignature = false;

    late final ByteData modelData;

    try {
      modelData = await rootBundle.load(modelAssetPath);
    } catch (error, stackTrace) {
      _lastError = 'Asset not found in app bundle: $modelAssetPath';
      debugPrint('Failed to verify model asset: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    final modelBytes = modelData.buffer.asUint8List();
    _hasValidTfliteSignature = _looksLikeTflite(modelBytes);
    if (!_hasValidTfliteSignature) {
      _lastError =
          'Model file is bundled but does not look like a valid .tflite flatbuffer (missing TFL3 signature).';
      return;
    }

    final errors = <String>[];

    try {
      _interpreter = await Interpreter.fromAsset(modelAssetPath);
      final interpreter = _interpreter;
      if (interpreter == null) {
        _lastError = 'Interpreter initialization returned null unexpectedly.';
        return;
      }
      _captureInputShape(interpreter);
      return;
    } catch (error, stackTrace) {
      errors.add('fromAsset(default): $error');
      debugPrint('TFLite init attempt 1 failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      final options = InterpreterOptions()..threads = 1;
      _interpreter = Interpreter.fromBuffer(modelBytes, options: options);
      final interpreter = _interpreter;
      if (interpreter == null) {
        _lastError = 'Interpreter initialization returned null unexpectedly.';
        return;
      }
      _captureInputShape(interpreter);
      return;
    } catch (error, stackTrace) {
      errors.add('fromBuffer(threads=1): $error');
      debugPrint('TFLite init attempt 2 failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    _interpreter = null;
    final joinedErrors = errors.join(' | ');
    if (joinedErrors.contains("FULLY_CONNECTED") &&
        joinedErrors.contains("version") &&
        joinedErrors.contains("Unable to create interpreter")) {
      _lastError =
          'Interpreter init failed: model uses newer FULLY_CONNECTED op version than app runtime. Re-convert model from original source using tools/model_conversion/convert_fall_model.py (prefer TFLITE_BUILTINS, fallback SELECT_TF_OPS). Details: $joinedErrors';
      return;
    }

    _lastError =
        'Interpreter init failed after ${errors.length} attempts. Likely model/runtime incompatibility (unsupported ops such as SELECT_TF_OPS, unsupported tensor types, or converter/runtime version mismatch). Details: $joinedErrors';
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }

  FallResult runInference(List<SensorFrame> window) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      return const FallResult(fallProbability: 0);
    }

    final normalizedWindow = _buildAndNormalizeModelInput(window);
    final input = [normalizedWindow];
    final outputCount = interpreter.getOutputTensors().length;
    final outputs = <int, Object>{};
    for (var i = 0; i < outputCount; i++) {
      final outputShape = interpreter.getOutputTensor(i).shape;
      outputs[i] = _createNestedBuffer(outputShape);
    }

    interpreter.runForMultipleInputs([input], outputs);

    final rawOutputs = <double>[];
    final scalarOutputCandidates = <double>[];
    for (var i = 0; i < outputCount; i++) {
      final values = <double>[];
      _flattenNumeric(outputs[i], values);
      rawOutputs.addAll(values);
      if (values.length == 1) {
        scalarOutputCandidates.add(values.first);
      }
    }

    final probabilitySource = scalarOutputCandidates.isNotEmpty
        ? scalarOutputCandidates
        : rawOutputs;
    final probability = probabilitySource.isEmpty
        ? 0.0
        : probabilitySource.reduce(math.max).clamp(0.0, 1.0);

    return FallResult(fallProbability: probability, rawOutputs: rawOutputs);
  }

  List<List<double>> _buildAndNormalizeModelInput(List<SensorFrame> window) {
    if (window.isEmpty) {
      return List<List<double>>.generate(
        _expectedTimesteps,
        (_) => List<double>.filled(_expectedFeatureCount, 0, growable: false),
        growable: false,
      );
    }

    final fullFeatures = <List<double>>[];
    double? prevAccMag;
    for (final frame in window) {
      final accMag = math.sqrt(
        frame.ax * frame.ax + frame.ay * frame.ay + frame.az * frame.az,
      );
      final gyroMag = math.sqrt(
        frame.gx * frame.gx + frame.gy * frame.gy + frame.gz * frame.gz,
      );
      final deltaAccMag = prevAccMag == null ? 0.0 : accMag - prevAccMag;
      prevAccMag = accMag;

      fullFeatures.add([
        frame.ax,
        frame.ay,
        frame.az,
        frame.gx,
        frame.gy,
        frame.gz,
        accMag,
        gyroMag,
        deltaAccMag,
      ]);
    }

    List<List<double>> timeAligned;
    if (fullFeatures.length >= _expectedTimesteps) {
      timeAligned = fullFeatures
          .sublist(fullFeatures.length - _expectedTimesteps)
          .toList(growable: false);
    } else {
      final padRow = fullFeatures.first;
      final padding = List<List<double>>.generate(
        _expectedTimesteps - fullFeatures.length,
        (_) => List<double>.from(padRow, growable: false),
        growable: false,
      );
      timeAligned = <List<double>>[...padding, ...fullFeatures];
    }

    final rows = timeAligned
        .map((row) {
          if (_expectedFeatureCount <= row.length) {
            return row.sublist(0, _expectedFeatureCount);
          }
          return <double>[
            ...row,
            ...List<double>.filled(_expectedFeatureCount - row.length, 0),
          ];
        })
        .toList(growable: false);

    final featureCount = _expectedFeatureCount;
    final means = List<double>.filled(featureCount, 0);
    final stds = List<double>.filled(featureCount, 0);

    for (final row in rows) {
      for (var i = 0; i < featureCount; i++) {
        means[i] += row[i];
      }
    }

    for (var i = 0; i < featureCount; i++) {
      means[i] /= rows.length;
    }

    for (final row in rows) {
      for (var i = 0; i < featureCount; i++) {
        final diff = row[i] - means[i];
        stds[i] += diff * diff;
      }
    }

    for (var i = 0; i < featureCount; i++) {
      stds[i] = math.sqrt(stds[i] / rows.length);
      if (stds[i] == 0) {
        stds[i] = 1;
      }
    }

    return rows
        .map(
          (row) => List<double>.generate(
            featureCount,
            (index) => (row[index] - means[index]) / stds[index],
            growable: false,
          ),
        )
        .toList(growable: false);
  }

  dynamic _createNestedBuffer(List<int> shape) {
    if (shape.isEmpty) {
      return 0.0;
    }

    return List<dynamic>.generate(
      shape.first,
      (_) => _createNestedBuffer(shape.sublist(1)),
      growable: false,
    );
  }

  void _flattenNumeric(dynamic input, List<double> output) {
    if (input is num) {
      output.add(input.toDouble());
      return;
    }

    if (input is List) {
      for (final item in input) {
        _flattenNumeric(item, output);
      }
    }
  }

  bool _looksLikeTflite(Uint8List bytes) {
    if (bytes.length < 8) return false;
    return bytes[4] == 0x54 && // T
        bytes[5] == 0x46 && // F
        bytes[6] == 0x4c && // L
        bytes[7] == 0x33; // 3
  }

  void _captureInputShape(Interpreter interpreter) {
    final shape = interpreter.getInputTensor(0).shape;
    if (shape.length >= 3) {
      _expectedTimesteps = shape[1] > 0 ? shape[1] : _expectedTimesteps;
      _expectedFeatureCount = shape[2] > 0 ? shape[2] : _expectedFeatureCount;
    }
  }
}
