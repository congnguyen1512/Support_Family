class HealthMetric {
  const HealthMetric({
    required this.label,
    required this.value,
    this.unit = '',
    this.trend = '',
  });

  final String label;
  final String value;
  final String unit;
  final String trend;
}
