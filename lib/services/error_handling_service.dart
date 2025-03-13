import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ErrorHandlingService {
  // Singleton pattern
  static ErrorHandlingService? _instance;
  static ErrorHandlingService get instance {
    _instance ??= ErrorHandlingService._();
    return _instance!;
  }

  ErrorHandlingService._();

  // Logger for consistent error logging
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Show user-friendly error messages
  void showErrorToUser(BuildContext context, String message,
      {bool fatal = false, VoidCallback? onRetry}) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show snackbar with option to retry if provided
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: fatal ? Colors.red.shade800 : Colors.orange.shade800,
      behavior: SnackBarBehavior.floating,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              onPressed: onRetry,
              textColor: Colors.white,
            )
          : null,
      duration:
          fatal ? const Duration(seconds: 10) : const Duration(seconds: 4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Log errors for debugging/analytics
  void logError(String source, dynamic error, StackTrace? stackTrace) {
    _logger.e('[$source] Error occurred', error, stackTrace);
  }

  // Handle specific error types differently
  void handleException(BuildContext context, String source, dynamic error,
      {VoidCallback? onRetry}) {
    logError(source, error, null);

    if (error is TimeoutException) {
      showErrorToUser(
        context,
        'Operation timed out. Please check your connection and try again.',
        onRetry: onRetry,
      );
    } else if (error is SocketException ||
        error.toString().contains('SocketException')) {
      showErrorToUser(
        context,
        'Network error. Please check your internet connection.',
        onRetry: onRetry,
      );
    } else if (error is FormatException) {
      showErrorToUser(context, 'Data format error. Please contact support.');
    } else {
      showErrorToUser(
        context,
        'Something went wrong. Please try again.',
        onRetry: onRetry,
      );
    }
  }

  // Check if error is critical
  bool isCriticalError(dynamic error) {
    return error is OutOfMemoryError ||
        error is StackOverflowError ||
        error.toString().contains('Failed assertion');
  }
}
