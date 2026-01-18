import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  
  AppException(this.message, [this.stackTrace]);
  
  @override
  String toString() => '$runtimeType($message)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException([String message = 'Connection timeout', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class ReceiveTimeoutException extends NetworkException {
  ReceiveTimeoutException([String message = 'Receive timeout', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class SendTimeoutException extends NetworkException {
  SendTimeoutException([String message = 'Send timeout', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class BadRequestException extends NetworkException {
  BadRequestException([String message = 'Bad request', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException([String message = 'Unauthorized', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class ForbiddenException extends NetworkException {
  ForbiddenException([String message = 'Forbidden', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class NotFoundException extends NetworkException {
  NotFoundException([String message = 'Not found', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class ConflictException extends NetworkException {
  ConflictException([String message = 'Conflict', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class InternalServerException extends NetworkException {
  InternalServerException([String message = 'Internal server error', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class UnknownException extends NetworkException {
  UnknownException([String message = 'Unknown error occurred', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class CancelledException extends NetworkException {
  CancelledException([String message = 'Request cancelled', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  
  ValidationException(String message, {this.fieldErrors, StackTrace? stackTrace})
      : super(message, stackTrace);
}

/// Data-related exceptions
class DataParsingException extends AppException {
  DataParsingException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class EmptyDataException extends AppException {
  EmptyDataException([String message = 'No data available', StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  AuthenticationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  BusinessLogicException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Error handler utility class
class ErrorHandler {
  /// Handles different types of errors and converts them to appropriate AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    }

    if (error is SocketException) {
      return NetworkException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        stackTrace,
      );
    }

    if (error is FormatException) {
      return DataParsingException(
        'Format data tidak valid. Terjadi kesalahan dalam pengolahan data.',
        stackTrace,
      );
    }

    if (error is TimeoutException) {
      return ReceiveTimeoutException(
        'Waktu permintaan habis. Silakan coba lagi.',
        stackTrace,
      );
    }

    if (error is TypeError) {
      return DataParsingException(
        'Jenis data tidak sesuai. Terjadi kesalahan dalam pengolahan data.',
        stackTrace,
      );
    }

    if (error is ArgumentError) {
      return ValidationException(
        'Argumen tidak valid: ${error.message}',
        stackTrace: stackTrace,
      );
    }

    // Default error
    return UnknownException(
      error.toString(),
      stackTrace,
    );
  }

  /// Handles Dio-specific errors and maps them to appropriate exceptions
  static AppException _handleDioError(DioException error, StackTrace? stackTrace) {
    String message = 'Terjadi kesalahan jaringan';
    String type = 'NETWORK_ERROR';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Waktu koneksi habis. Silakan coba lagi.';
        type = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Waktu pengiriman habis. Silakan coba lagi.';
        type = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Waktu penerimaan habis. Silakan coba lagi.';
        type = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        int? statusCode = error.response?.statusCode;
        String? statusMessage = error.response?.statusMessage;

        switch (statusCode) {
          case 400:
            message = 'Permintaan tidak valid. Silakan periksa data yang dimasukkan.';
            type = 'BAD_REQUEST';
            break;
          case 401:
            message = 'Akses ditolak. Silakan login kembali.';
            type = 'UNAUTHORIZED';
            break;
          case 403:
            message = 'Akses dilarang. Anda tidak memiliki izin untuk melakukan ini.';
            type = 'FORBIDDEN';
            break;
          case 404:
            message = 'Data tidak ditemukan.';
            type = 'NOT_FOUND';
            break;
          case 422:
            message = 'Data tidak valid. Silakan periksa kembali inputan Anda.';
            type = 'VALIDATION_ERROR';
            break;
          case 500:
            message = 'Terjadi kesalahan server. Silakan coba lagi nanti.';
            type = 'SERVER_ERROR';
            break;
          default:
            message = 'Kesalahan server: ${statusCode ?? "Unknown"} - ${statusMessage ?? "No message"}';
            type = 'SERVER_ERROR';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Permintaan dibatalkan.';
        type = 'REQUEST_CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = 'Kesalahan koneksi. Periksa koneksi internet Anda.';
        type = 'CONNECTION_ERROR';
        break;
      case DioExceptionType.badCertificate:
        message = 'Kesalahan sertifikat keamanan.';
        type = 'CERTIFICATE_ERROR';
        break;
      case DioExceptionType.unknown:
        message = 'Terjadi kesalahan jaringan yang tidak diketahui.';
        type = 'NETWORK_ERROR';
        break;
    }

    return UnknownException(message, stackTrace);
  }

  /// Shows error message to user using SnackBar
  static void showErrorSnackBar(BuildContext context, AppException exception) {
    String message = exception.message;
    
    // Customize message based on exception type
    if (exception is UnauthorizedException) {
      message = 'Sesi Anda telah habis. Silakan login kembali.';
    } else if (exception is NetworkException) {
      message = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    } else if (exception is ValidationException) {
      message = 'Data tidak valid. Silakan periksa kembali inputan Anda.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Extension to easily convert errors to AppException
extension ErrorExtension on Object {
  AppException toAppException([StackTrace? stackTrace]) {
    return ErrorHandler.handle(this, stackTrace);
  }
}