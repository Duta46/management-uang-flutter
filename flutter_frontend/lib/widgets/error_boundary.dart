import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../widgets/error_display.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppError error, VoidCallback reset)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;

  void _reset() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.onError != null) {
        return widget.onError!(_error!, _reset);
      }
      return ErrorDisplay(
        error: _error!,
        onRetry: _reset,
        showDetails: true,
      );
    }

    return widget.child;
  }
}