class QuickContact {
  const QuickContact({
    this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.memberUid,
  });

  final int? id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final String? memberUid;

  factory QuickContact.fromJson(Map<String, dynamic> json) {
    return QuickContact(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      memberUid: json['member_uid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (memberUid != null) 'member_uid': memberUid,
    };
  }
}
