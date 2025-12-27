import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          if (showDetails) ...[
            const SizedBox(height: 8),
            Text(
              error.type,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }

  String _getErrorMessage() {
    switch (error.type) {
      case 'UNAUTHORIZED':
        return 'Akses ditolak. Silakan login kembali.';
      case 'NETWORK_ERROR':
      case 'CONNECTION_ERROR':
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case 'TIMEOUT_ERROR':
      case 'CONNECTION_TIMEOUT':
        return 'Waktu permintaan habis. Silakan coba lagi.';
      case 'NOT_FOUND':
        return 'Data tidak ditemukan.';
      case 'SERVER_ERROR':
        return 'Terjadi kesalahan server. Silakan coba lagi nanti.';
      case 'VALIDATION_ERROR':
        return 'Data tidak valid. Silakan periksa kembali inputan Anda.';
      case 'BAD_REQUEST':
        return 'Permintaan tidak valid. Silakan periksa data yang dimasukkan.';
      default:
        return error.message;
    }
  }
}

class DetailedErrorDialog extends StatelessWidget {
  final AppError error;

  const DetailedErrorDialog({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detail Kesalahan'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jenis: ${error.type}'),
            const SizedBox(height: 8),
            Text('Pesan: ${error.message}'),
            const SizedBox(height: 8),
            if (error.originalError != null)
              Text('Error Asli: ${error.originalError}'),
            const SizedBox(height: 8),
            if (error.stackTrace != null) ...[
              const Text('Stack Trace:'),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  error.stackTrace.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}