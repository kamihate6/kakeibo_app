import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = '処理中...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isLoading)
          Container(
            color: Colors.black38,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
