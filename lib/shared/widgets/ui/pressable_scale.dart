import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Scales its [child] down while pressed and fires a light haptic on tap.
/// Without [onTap] it renders [child] unchanged.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: animate ? const Duration(milliseconds: 120) : Duration.zero,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
