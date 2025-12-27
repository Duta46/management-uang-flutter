import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';

class AppError {
  final String message;
  final String type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, originalError: $originalError}';
  }
}

class ErrorHandler {
  static AppError handle(dynamic error, StackTrace? stackTrace) {
    print('Raw error: $error');
    print('Stack trace: $stackTrace');

    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    }

    if (error is SocketException) {
      return AppError(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        type: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return AppError(
        message: 'Format data tidak valid. Terjadi kesalahan dalam pengolahan data.',
        type: 'FORMAT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        message: 'Waktu permintaan habis. Silakan coba lagi.',
        type: 'TIMEOUT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TypeError) {
      return AppError(
        message: 'Jenis data tidak sesuai. Terjadi kesalahan dalam pengolahan data.',
        type: 'TYPE_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Default error
    return AppError(
      message: error.toString(),
      type: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError _handleDioError(DioException error, StackTrace? stackTrace) {
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

    return AppError(
      message: message,
      type: type,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static String getDetailedErrorMessage(AppError error) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Error Type: ${error.type}');
    buffer.writeln('Message: ${error.message}');
    
    if (error.originalError != null) {
      buffer.writeln('Original Error: ${error.originalError}');
    }
    
    if (error.stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(error.stackTrace);
    }
    
    return buffer.toString();
  }
}