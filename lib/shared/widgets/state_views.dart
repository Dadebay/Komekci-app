import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

/// Standard "nothing here yet" panel: icon badge, title, supporting text and
/// an optional action. Used for empty search results, empty lists, and (via
/// [RetryErrorState] / [OfflineState]) for retryable and offline states too.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.text, this.action});
  final IconData icon;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.surface),
            child: AppIcon(icon, color: t.accent, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// A failed load with a retry action — for real API errors, not empty results.
class RetryErrorState extends StatelessWidget {
  const RetryErrorState({
    super.key,
    required this.title,
    required this.text,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });
  final String title;
  final String text;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return EmptyState(
      icon: Icons.warning_amber_rounded,
      title: title,
      text: text,
      action: OutlinedButton(
        onPressed: onRetry,
        style: OutlinedButton.styleFrom(foregroundColor: t.textPrimary, side: BorderSide(color: t.border)),
        child: Text(retryLabel),
      ),
    );
  }
}

/// No network connection — distinct from [RetryErrorState] so screens can
/// tell the user "you're offline" instead of implying the server failed.
class OfflineState extends StatelessWidget {
  const OfflineState({super.key, required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => EmptyState(icon: Icons.wifi_off_rounded, title: title, text: text);
}

/// A single pulsing placeholder block for skeleton loading rows. Plain
/// opacity animation only — no shimmer package — to stay cheap on low-RAM
/// devices per the app's performance rule.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.height = 80, this.borderRadius = 16});
  final double height;
  final double borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: t.border.withValues(alpha: .3 + _controller.value * .25),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// A column of [LoadingSkeleton] rows — drop-in placeholder while a list
/// screen's real data is loading.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3, this.itemHeight = 80});
  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      count,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: LoadingSkeleton(height: itemHeight),
      ),
    ),
  );
}
