import 'dart:async';

import 'package:flutter/material.dart';

/// Fades [child] in with a 12 px upward slide, delayed 40 ms x [index]
/// (index capped at 8). Runs once on first build.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final delay = Duration(milliseconds: 40 * widget.index.clamp(0, 8));
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}
