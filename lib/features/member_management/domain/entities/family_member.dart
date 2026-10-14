class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    this.isOnline = false,
  });

  final String name;
  final String role;
  final String imageUrl;
  final bool isOnline;
}
