import 'package:flutter/material.dart';

/// Animates a number from its previous value to [value] over 600 ms and
/// rebuilds [builder] with the in-flight value. The first build also counts
/// up from 0.
class AnimatedCount extends StatefulWidget {
  const AnimatedCount({super.key, required this.value, required this.builder});

  final double value;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount> {
  double _from = 0;

  @override
  void didUpdateWidget(AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.builder(context, widget.value);
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(begin: _from, end: widget.value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => widget.builder(context, v),
    );
  }
}
