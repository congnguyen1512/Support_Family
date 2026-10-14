import 'dart:async';

import 'package:family_guard/core/fall_detection/data/fall_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FallDetectionDebugPanel extends StatefulWidget {
  const FallDetectionDebugPanel({super.key});

  @override
  State<FallDetectionDebugPanel> createState() =>
      _FallDetectionDebugPanelState();
}

class _FallDetectionDebugPanelState extends State<FallDetectionDebugPanel> {
  bool _isExpanded = false;
  double _currentProbability = 0;
  StreamSubscription<double>? _probabilitySubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _probabilitySubscription = FallDetectionService.instance.probabilityStream
        .listen((prob) {
          setState(() => _currentProbability = prob);
        });
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _probabilitySubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = FallDetectionService.instance;
    final history = service.eventHistory;
    final modelReady = service.modelReady;
    final modelLoadError = service.modelLoadError;
    final lastSensorFrameAt = service.lastSensorFrameAt;
    final sensorError = service.sensorError;
    final pipelineError = service.lastPipelineError;
    final sensorFrameCount = service.sensorFrameCount;
    final bufferedSamples = service.bufferedSamples;
    final requiredWindowSamples = service.requiredWindowSamples;
    final inferenceCount = service.inferenceCount;
    final isRunning = service.isRunning;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? 320 : 60,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fall Detection Debug',
                    style: GoogleFonts.publicSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow(
                      'Model',
                      modelReady ? '✓ Ready' : '✗ Not Ready',
                      modelReady ? Colors.green : Colors.red,
                    ),
                    if (!modelReady && modelLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          modelLoadError,
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFFFFB4B4),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    if (!modelReady)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () async {
                              await service.reloadModel();
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              'Retry Load Model',
                              style: GoogleFonts.publicSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Monitoring',
                      isRunning ? '✓ Running' : '✗ Stopped',
                      isRunning ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Sensor Frames',
                      sensorFrameCount.toString(),
                      sensorFrameCount > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Window Fill',
                      '$bufferedSamples/$requiredWindowSamples',
                      bufferedSamples >= requiredWindowSamples
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Inference Count',
                      inferenceCount.toString(),
                      inferenceCount > 0 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Probability',
                      _currentProbability.toStringAsFixed(3),
                      _getProbabilityColor(_currentProbability),
                    ),
                    if (lastSensorFrameAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Last sensor frame: ${DateTime.now().difference(lastSensorFrameAt).inMilliseconds} ms ago',
                          style: GoogleFonts.publicSans(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (sensorError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Sensor error: $sensorError',
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFFFFB4B4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (pipelineError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Inference error: $pipelineError',
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFFFFB4B4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Events (${history.length})',
                      style: GoogleFonts.publicSans(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      Text(
                        'No events yet',
                        style: GoogleFonts.publicSans(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      )
                    else
                      ...history.reversed.take(5).map((event) {
                        final diffMinutes = DateTime.now()
                            .difference(event.detectedAt)
                            .inSeconds;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${event.probability.toStringAsFixed(2)} (${diffMinutes}s ago)',
                            style: GoogleFonts.publicSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProbabilityColor(double prob) {
    if (prob >= 0.9) return Colors.red;
    if (prob >= 0.7) return Colors.orange;
    if (prob >= 0.5) return Colors.yellow;
    return Colors.green;
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.publicSans(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
