sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($code): $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
