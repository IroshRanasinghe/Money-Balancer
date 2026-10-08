import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/premium/premium_feature.dart';
import 'presentation/pages/premium_page.dart';

/// PremiumBloc is app-wide (provided in app.dart). The reason that opened the
/// paywall arrives in `state.extra`.
Widget premiumRouteBuilder(BuildContext context, GoRouterState state) =>
    PremiumPage(
      reason: state.extra is PremiumFeature
          ? state.extra as PremiumFeature
          : null,
    );
