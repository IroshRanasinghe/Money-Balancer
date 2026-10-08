import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/config/constants.dart';
import '../core/premium/premium_feature.dart';

/// Opens the paywall for [feature]. Deferred a microtask so a form sheet that
/// is closing in the same listener pass is popped first.
void openPaywall(BuildContext context, PremiumFeature feature) {
  scheduleMicrotask(() {
    if (!context.mounted) return;
    context.push(AppRoutes.premium, extra: feature);
  });
}
