import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable implements Exception {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out'});
}

class InvalidApiResponseFailure extends Failure {
  const InvalidApiResponseFailure({super.message = 'Invalid API response'});
}

class ImageCompressionFailure extends Failure {
  const ImageCompressionFailure({super.message = 'Image compression failed'});
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({super.message = 'Permission denied'});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({super.message = 'Database operation failed'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Something went wrong'});
}
