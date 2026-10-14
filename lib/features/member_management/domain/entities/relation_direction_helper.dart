class RelationDirectionHelper {
  const RelationDirectionHelper._();

  static String resolveReverseRelation(String relationType) {
    final normalized = relationType.trim().toLowerCase();
    switch (normalized) {
      case 'vo':
      case 'vợ':
        return 'Chong';
      case 'chong':
      case 'chồng':
        return 'Vo';
      case 'bo':
      case 'bố':
      case 'cha':
      case 'ba':
        return 'Con';
      case 'me':
      case 'mẹ':
        return 'Con';
      case 'con':
        return 'Bo/Me';
      case 'ong':
      case 'ông':
        return 'Chau';
      case 'ba noi':
      case 'ba ngoai':
      case 'bà':
      case 'bà nội':
      case 'bà ngoại':
        return 'Chau';
      case 'anh':
      case 'chị':
      case 'chi':
        return 'Em';
      case 'em':
        return 'Anh/Chi';
      default:
        return relationType;
    }
  }
}
