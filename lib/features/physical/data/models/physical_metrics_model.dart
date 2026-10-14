class PhysicalMetricsModel {
  final int id;
  final String memberUid;
  final String metricDate;
  final int steps;
  final int stepsGoal;
  final int calories;
  final int caloriesGoal;
  final int activeMinutes;
  final int minutesGoal;

  const PhysicalMetricsModel({
    this.id = 0,
    required this.memberUid,
    required this.metricDate,
    this.steps = 0,
    this.stepsGoal = 10000,
    this.calories = 0,
    this.caloriesGoal = 500,
    this.activeMinutes = 0,
    this.minutesGoal = 60,
  });

  factory PhysicalMetricsModel.fromJson(Map<String, dynamic> json) {
    return PhysicalMetricsModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      memberUid: json['member_uid']?.toString() ?? '',
      metricDate: json['metric_date']?.toString() ?? '',
      steps: json['steps'] is int ? json['steps'] as int : int.tryParse('${json['steps']}') ?? 0,
      stepsGoal: json['steps_goal'] is int ? json['steps_goal'] as int : int.tryParse('${json['steps_goal']}') ?? 10000,
      calories: json['calories'] is int ? json['calories'] as int : int.tryParse('${json['calories']}') ?? 0,
      caloriesGoal: json['calories_goal'] is int ? json['calories_goal'] as int : int.tryParse('${json['calories_goal']}') ?? 500,
      activeMinutes: json['active_minutes'] is int ? json['active_minutes'] as int : int.tryParse('${json['active_minutes']}') ?? 0,
      minutesGoal: json['minutes_goal'] is int ? json['minutes_goal'] as int : int.tryParse('${json['minutes_goal']}') ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_uid': memberUid,
      'metric_date': metricDate,
      'steps': steps,
      'steps_goal': stepsGoal,
      'calories': calories,
      'calories_goal': caloriesGoal,
      'active_minutes': activeMinutes,
      'minutes_goal': minutesGoal,
    };
  }
}
