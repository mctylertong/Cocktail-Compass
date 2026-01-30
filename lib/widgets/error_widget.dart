import 'package:flutter/material.dart';
import '../services/error_service.dart';

/// A reusable error display widget that shows user-friendly error messages
/// with appropriate icons and optional retry functionality.
class ErrorDisplayWidget extends StatelessWidget {
  final AppException? error;
  final String? message;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorDisplayWidget({
    Key? key,
    this.error,
    this.message,
    this.onRetry,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ??
        (error != null ? ErrorService.getUserMessage(error!) : 'Something went wrong');
    final errorType = error?.type ?? AppErrorType.unknown;
    final canRetry = error != null ? ErrorService.isRetryable(errorType) : false;

    if (compact) {
      return _buildCompactError(context, displayMessage, errorType, canRetry);
    }

    return _buildFullError(context, displayMessage, errorType, canRetry);
  }

  Widget _buildFullError(
    BuildContext context,
    String message,
    AppErrorType type,
    bool canRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(type),
              size: 64,
              color: _getColor(type),
            ),
            const SizedBox(height: 16),
            Text(
              _getTitle(type),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactError(
    BuildContext context,
    String message,
    AppErrorType type,
    bool canRetry,
  ) {
    final color = _getColor(type);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(type),
            color: _getColor(type),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
          if (canRetry && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: _getColor(type),
              tooltip: 'Try Again',
            ),
        ],
      ),
    );
  }

  IconData _getIcon(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return Icons.wifi_off;
      case AppErrorType.server:
        return Icons.cloud_off;
      case AppErrorType.timeout:
        return Icons.timer_off;
      case AppErrorType.notFound:
        return Icons.search_off;
      case AppErrorType.unauthorized:
        return Icons.lock_outline;
      case AppErrorType.rateLimit:
        return Icons.speed;
      case AppErrorType.apiKey:
        return Icons.vpn_key_off;
      case AppErrorType.parsing:
        return Icons.broken_image;
      case AppErrorType.database:
        return Icons.storage;
      case AppErrorType.location:
        return Icons.location_off;
      case AppErrorType.permission:
        return Icons.block;
      case AppErrorType.unknown:
        return Icons.error_outline;
    }
  }

  Color _getColor(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.timeout:
        return Colors.orange;
      case AppErrorType.server:
      case AppErrorType.rateLimit:
        return Colors.red;
      case AppErrorType.notFound:
        return Colors.grey;
      case AppErrorType.unauthorized:
      case AppErrorType.permission:
        return Colors.deepPurple;
      case AppErrorType.apiKey:
        return Colors.amber;
      case AppErrorType.parsing:
      case AppErrorType.database:
        return Colors.brown;
      case AppErrorType.location:
        return Colors.blue;
      case AppErrorType.unknown:
        return Colors.red;
    }
  }

  String _getTitle(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return 'No Internet Connection';
      case AppErrorType.server:
        return 'Server Error';
      case AppErrorType.timeout:
        return 'Request Timed Out';
      case AppErrorType.notFound:
        return 'Not Found';
      case AppErrorType.unauthorized:
        return 'Access Denied';
      case AppErrorType.rateLimit:
        return 'Too Many Requests';
      case AppErrorType.apiKey:
        return 'Configuration Error';
      case AppErrorType.parsing:
        return 'Data Error';
      case AppErrorType.database:
        return 'Storage Error';
      case AppErrorType.location:
        return 'Location Error';
      case AppErrorType.permission:
        return 'Permission Required';
      case AppErrorType.unknown:
        return 'Something Went Wrong';
    }
  }
}

/// A snackbar helper for showing error messages
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    AppException? error,
    String? message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final displayMessage = message ??
        (error != null ? ErrorService.getUserMessage(error) : 'Something went wrong');
    final canRetry = error != null && ErrorService.isRetryable(error.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: canRetry && onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
