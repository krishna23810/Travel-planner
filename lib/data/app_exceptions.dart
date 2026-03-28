

class AppExceptions implements Exception {
  final String message;
  final String prefix;
  AppExceptions({required this.message, required this.prefix});

  @override
  String toString() {
    return '$prefix\n$message';
  }

}

class FetchDataException extends AppExceptions {
  FetchDataException({required String message}) : super(message: message, prefix: 'Error during communication');
}

class BadRequestException extends AppExceptions {
  BadRequestException({required String message}) : super(message: message, prefix: 'Invalid request');
}

class UnauthorizedException extends AppExceptions {
  UnauthorizedException({required String message}) : super(message: message, prefix: 'Unauthorized');
}

class NotFoundException extends AppExceptions {
  NotFoundException({required String message}) : super(message: message, prefix: 'Not found');
}

class ServerException extends AppExceptions {
  ServerException({required String message}) : super(message: message, prefix: 'Server error');
}

class InvalidInputException extends AppExceptions {
  InvalidInputException({required String message}) : super(message: message, prefix: 'Invalid input');
}
