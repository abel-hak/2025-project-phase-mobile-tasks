class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({required this.message});
}

class ForbiddenException implements Exception {
  final String message;

  ForbiddenException({required this.message});
}
