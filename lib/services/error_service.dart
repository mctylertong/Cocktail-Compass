import 'dart:async';
import 'dart:io';

/// Custom exception types for better error categorization
class AppException implements Exception {
  final String message;
  final String? details;
  final AppErrorType type;

  AppException(this.message, {this.details, this.type = AppErrorType.unknown});

  @override
  String toString() => message;
}

enum AppErrorType {
  network,
  server,
  timeout,
  notFound,
  unauthorized,
  rateLimit,
  apiKey,
  parsing,
  database,
  location,
  permission,
  unknown,
}

/// Network-specific exception
class NetworkException extends AppException {
  NetworkException([String? details])
      : super(
          'No internet connection',
          details: details,
          type: AppErrorType.network,
        );
}

/// Server error exception (5xx errors)
class ServerException extends AppException {
  final int? statusCode;

  ServerException({this.statusCode, String? details})
      : super(
          'Server error occurred',
          details: details ?? 'Status code: $statusCode',
          type: AppErrorType.server,
        );
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException([String? details])
      : super(
          'Request timed out',
          details: details,
          type: AppErrorType.timeout,
        );
}

/// Not found exception (404)
class NotFoundException extends AppException {
  NotFoundException([String? details])
      : super(
          'Resource not found',
          details: details,
          type: AppErrorType.notFound,
        );
}

/// API key error
class ApiKeyException extends AppException {
  ApiKeyException([String? details])
      : super(
          'API key error',
          details: details,
          type: AppErrorType.apiKey,
        );
}

/// Rate limit exception
class RateLimitException extends AppException {
  RateLimitException([String? details])
      : super(
          'Too many requests',
          details: details,
          type: AppErrorType.rateLimit,
        );
}

/// Data parsing exception
class ParsingException extends AppException {
  ParsingException([String? details])
      : super(
          'Failed to process data',
          details: details,
          type: AppErrorType.parsing,
        );
}

/// Location permission exception
class LocationPermissionException extends AppException {
  LocationPermissionException([String? details])
      : super(
          'Location permission required',
          details: details,
          type: AppErrorType.permission,
        );
}

/// Centralized error handling service
class ErrorService {
  /// Converts various exception types to user-friendly AppException
  static AppException handleException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(error.message);
    }

    if (error is HttpException) {
      return ServerException(details: error.message);
    }

    if (error is FormatException) {
      return ParsingException(error.message);
    }

    if (error is AsyncError) {
      return handleException(error.error);
    }

    // Default unknown error
    return AppException(
      'Something went wrong',
      details: error.toString(),
      type: AppErrorType.unknown,
    );
  }

  /// Returns a user-friendly error message based on error type
  static String getUserMessage(AppException error) {
    switch (error.type) {
      case AppErrorType.network:
        return 'No internet connection. Please check your network and try again.';
      case AppErrorType.server:
        return 'Server is temporarily unavailable. Please try again later.';
      case AppErrorType.timeout:
        return 'Request timed out. Please check your connection and try again.';
      case AppErrorType.notFound:
        return 'The requested content was not found.';
      case AppErrorType.unauthorized:
        return 'Authentication required. Please sign in again.';
      case AppErrorType.rateLimit:
        return 'Too many requests. Please wait a moment and try again.';
      case AppErrorType.apiKey:
        return 'API configuration error. Please contact support.';
      case AppErrorType.parsing:
        return 'Unable to process the response. Please try again.';
      case AppErrorType.database:
        return 'Database error occurred. Please restart the app.';
      case AppErrorType.location:
        return 'Unable to get your location. Please check your settings.';
      case AppErrorType.permission:
        return 'Permission required to continue.';
      case AppErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Returns an appropriate icon for the error type
  static String getErrorIcon(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return 'wifi_off';
      case AppErrorType.server:
        return 'cloud_off';
      case AppErrorType.timeout:
        return 'timer_off';
      case AppErrorType.notFound:
        return 'search_off';
      case AppErrorType.location:
      case AppErrorType.permission:
        return 'location_off';
      case AppErrorType.rateLimit:
        return 'speed';
      default:
        return 'error_outline';
    }
  }

  /// Check if the error is retryable
  static bool isRetryable(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.server:
      case AppErrorType.timeout:
      case AppErrorType.rateLimit:
        return true;
      case AppErrorType.notFound:
      case AppErrorType.unauthorized:
      case AppErrorType.apiKey:
      case AppErrorType.parsing:
      case AppErrorType.database:
      case AppErrorType.location:
      case AppErrorType.permission:
      case AppErrorType.unknown:
        return false;
    }
  }
}

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final AppException? error;

  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Map success value to another type
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data as T));
    }
    return Result.failure(error);
  }

  /// Execute callback based on result
  void when({
    required void Function(T data) success,
    required void Function(AppException error) failure,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else if (error != null) {
      failure(error!);
    }
  }
}
