import 'package:flutter/material.dart';

/// A reusable error display widget for showing error messages to users
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? additionalMessage;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;
  final bool showRetryButton;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.additionalMessage,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (additionalMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                additionalMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A loading indicator with optional error message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const LoadingIndicator({
    Key? key,
    this.message = 'Memuat...',
    this.isError = false,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return ErrorDisplay(
        message: errorMessage ?? 'Terjadi kesalahan',
        onRetry: onRetry,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// A widget that handles displaying content, loading state, or error state
class StatefulView<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;
  final String? loadingMessage;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final bool showEmptyAsError;

  const StatefulView({
    Key? key,
    required this.snapshot,
    required this.builder,
    this.loadingMessage,
    this.emptyMessage,
    this.emptyWidget,
    this.showEmptyAsError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.none:
        return LoadingIndicator(message: loadingMessage);
      case ConnectionState.active:
      case ConnectionState.done:
        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Terjadi Kesalahan',
            additionalMessage: snapshot.error.toString(),
            onRetry: () => {},
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data;
          
          // Check if data is a list and is empty
          if (data is List && data.isEmpty) {
            if (showEmptyAsError) {
              return ErrorDisplay(
                message: emptyMessage ?? 'Data kosong',
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                showRetryButton: false,
              );
            } else {
              return emptyWidget ?? 
                  Center(
                    child: Text(emptyMessage ?? 'Tidak ada data'),
                  );
            }
          }
          
          return builder(snapshot.data as T);
        } else {
          return ErrorDisplay(
            message: 'Tidak ada data',
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            showRetryButton: false,
          );
        }
    }
  }
}