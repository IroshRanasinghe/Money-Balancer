import 'package:flutter/material.dart';

/// Standard bottom-sheet body: title row, scrollable [child] that lifts above
/// the keyboard, optional pinned [actions] row, 20 px padding, safe area.
/// Use inside `showModalBottomSheet(isScrollControlled: true, ...)`.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;

  /// Widgets shown in a row under the body (e.g. a full-width submit button
  /// wrapped in `Expanded`).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      actions![i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
