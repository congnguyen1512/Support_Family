class SearchUser {
  const SearchUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.avata,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? avata;
}
