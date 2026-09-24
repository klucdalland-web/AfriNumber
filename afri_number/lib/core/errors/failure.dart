abstract class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Non autorisé']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors});

  final Map<String, dynamic>? errors;
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur est survenue']);
}
