import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared transition for pushed (non-tab) routes: fade plus a 4% upward slide
/// over 300 ms. Skipped when the platform asks to disable animations.
CustomTransitionPage<T> fadeSlidePage<T>({
  required GoRouterState state,
  required Widget child,
}) => CustomTransitionPage<T>(
  key: state.pageKey,
  name: state.name ?? state.path,
  arguments: state.extra,
  restorationId: state.pageKey.value,
  child: child,
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

/// Convenience wrapper turning a `GoRouterWidgetBuilder` into a page builder.
Page<void> Function(BuildContext, GoRouterState) fadeSlideBuilder(
  Widget Function(BuildContext, GoRouterState) builder,
) =>
    (context, state) =>
        fadeSlidePage(state: state, child: builder(context, state));
