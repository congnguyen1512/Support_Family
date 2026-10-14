class FallResult {
  const FallResult({required this.fallProbability, this.rawOutputs = const []});

  final double fallProbability;
  final List<double> rawOutputs;
}
