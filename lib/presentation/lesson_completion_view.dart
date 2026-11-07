import 'package:flutter/material.dart';

class LessonCompletionView extends StatelessWidget {
  const LessonCompletionView({
    required this.onRestart,
    required this.onReturnToMenu,
    super.key,
  });

  final VoidCallback onRestart;
  final VoidCallback onReturnToMenu;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text('درس تمام شد', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('می‌توانید دوباره از ابتدا شروع کنید.'),
          const SizedBox(height: 28),
          FilledButton(onPressed: onRestart, child: const Text('شروع دوباره')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onReturnToMenu,
            child: const Text('بازگشت به فهرست درس‌ها'),
          ),
        ],
      ),
    );
  }
}
