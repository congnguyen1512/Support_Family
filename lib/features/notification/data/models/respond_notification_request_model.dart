class RespondNotificationRequestModel {
  const RespondNotificationRequestModel({required this.action});

  final String action;

  Map<String, dynamic> toJson() {
    return {'action': action};
  }
}
