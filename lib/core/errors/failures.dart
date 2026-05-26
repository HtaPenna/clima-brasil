/// Representa uma falha no sistema seguindo os preceitos de Clean Architecture
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Erro de comunicação com o servidor/API
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Erro relacionado ao banco local ou cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Erro ao requisitar permissão ou obter localização GPS
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Erro de conexão com a internet
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
