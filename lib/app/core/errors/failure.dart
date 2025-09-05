import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:muslimdaily/app/core/errors/util_error_code.dart';

abstract class Failure {
  final String errorMessage;

  Failure({required this.errorMessage});
}

class OfflineFailure extends Failure {
  OfflineFailure({required super.errorMessage});
}

class EmptyCacheFailure extends Failure {
  EmptyCacheFailure({required super.errorMessage});
}

class ServerFailure extends Failure {
  ServerFailure({required super.errorMessage});

  factory ServerFailure.fromDioError(DioException error) {
    switch (error.type) {
      case DioException.connectionTimeout || DioException.receiveTimeout:
        return ServerFailure(errorMessage: 'Timeout Error: ${error.message}');
      case DioException.connectionError:
        return ServerFailure(
            errorMessage:
                'Response Error: ${error.response?.statusCode} - ${error.message}');
      case DioExceptionType.cancel:
        return ServerFailure(errorMessage: 'Other DioError: ${error.message}');
      case DioExceptionType.unknown:
        if (error.message!.contains('SocketException')) {
          return ServerFailure(errorMessage: 'No Internet connection');
        }
        return ServerFailure(errorMessage: 'unexpected error please try again');
      default:
        return ServerFailure(errorMessage: 'Unknown DioError occurred');
    }
  }
}

class FirebaseFailure extends Failure {
  FirebaseFailure({required super.errorMessage});
}

String generateErrorMessage(PlatformException e) {
  String authError = "";
  switch (e.code) {
    case ErrorCodes.ERROR_C0DE_NETWORK_ERROR:
      authError = ErrorMessages.ERROR_C0DE_NETWORK_ERROR;
      break;
    case ErrorCodes.ERROR_USER_NOT_FOUND:
      authError = ErrorMessages.ERROR_USER_NOT_FOUND;
      break;
    case ErrorCodes.ERROR_TOO_MANY_REQUESTS:
      authError = ErrorMessages.ERROR_TOO_MANY_REQUESTS;
      break;
    case ErrorCodes.ERROR_INVALID_EMAIL:
      authError = ErrorMessages.ERROR_INVALID_EMAIL;
      break;
    case ErrorCodes.ERROR_CODE_USER_DISABLED:
      authError = ErrorMessages.ERROR_CODE_USER_DISABLED;
      break;
    case ErrorCodes.ERROR_CODE_WRONG_PASSWORD:
      authError = ErrorMessages.ERROR_CODE_WRONG_PASSWORD;
      break;
    case ErrorCodes.ERROR_CODE_EMAIL_ALREADY_IN_USE:
      authError = ErrorMessages.ERROR_CODE_EMAIL_ALREADY_IN_USE;
      break;
    case ErrorCodes.ERROR_OPERATION_NOT_ALLOWED:
      authError = ErrorMessages.ERROR_OPERATION_NOT_ALLOWED;
      break;
    case ErrorCodes.ERROR_CODE_WEAK_PASSWORD:
      authError = ErrorMessages.ERROR_CODE_WEAK_PASSWORD;
      break;
    default:
      authError = ErrorMessages.DEFAULT;
      break;
  }
  return authError;
}
