import 'package:flutter/material.dart';

class LessonErrorView extends StatelessWidget {
  const LessonErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onRetry, child: const Text('تلاش دوباره')),
        ],
      ),
    );
  }
}
