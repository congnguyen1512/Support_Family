class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.processing,
    required this.uid,
    required this.relationshipId,
    this.fallLatitude,
    this.fallLongitude,
    this.senderName,
    this.senderRelation,
    this.createdAt,
  });

  final int id;
  final String title;
  final String content;
  final String processing;
  final String uid;
  final int? relationshipId;
  final double? fallLatitude;
  final double? fallLongitude;
  final String? senderName;
  final String? senderRelation;
  final DateTime? createdAt;

  AppNotification copyWith({
    int? id,
    String? title,
    String? content,
    String? processing,
    String? uid,
    int? relationshipId,
    double? fallLatitude,
    double? fallLongitude,
    String? senderName,
    String? senderRelation,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      processing: processing ?? this.processing,
      uid: uid ?? this.uid,
      relationshipId: relationshipId ?? this.relationshipId,
      fallLatitude: fallLatitude ?? this.fallLatitude,
      fallLongitude: fallLongitude ?? this.fallLongitude,
      senderName: senderName ?? this.senderName,
      senderRelation: senderRelation ?? this.senderRelation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
