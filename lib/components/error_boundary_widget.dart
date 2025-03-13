import 'package:flutter/material.dart';

class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const ErrorBoundaryWidget({
    required this.child,
    this.fallback,
    Key? key,
  }) : super(key: key);

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallback ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 32, color: Colors.orange),
                  const SizedBox(height: 8),
                  const Text(
                    'Something went wrong displaying this content',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        hasError = false;
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
    }

    // Set the error handler
    ErrorWidget.builder = (FlutterErrorDetails details) {
      hasError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return const SizedBox.shrink();
    };

    // Return the child widget
    return widget.child;
  }
}
