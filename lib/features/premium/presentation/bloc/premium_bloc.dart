import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_premium_packages.dart';
import '../../domain/usecases/get_premium_status.dart';
import '../../domain/usecases/is_store_available.dart';
import '../../domain/usecases/purchase_premium.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/set_debug_premium.dart';
import '../../domain/usecases/watch_premium_status.dart';
import 'premium_event.dart';
import 'premium_state.dart';

export 'premium_event.dart';
export 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  PremiumBloc(
    this._getStatus,
    this._getPackages,
    this._purchase,
    this._restore,
    this._watch,
    this._setDebugPremium,
    this._isStoreAvailable,
  ) : super(const PremiumState()) {
    on<PremiumStarted>(_onStarted);
    on<PremiumStatusPushed>(
        (e, emit) => emit(state.copyWith(status: e.status)));
    on<PremiumPurchaseRequested>(_onPurchase);
    on<PremiumRestoreRequested>(_onRestore);
    on<PremiumDebugToggled>(_onDebugToggled);
  }

  final GetPremiumStatus _getStatus;
  final GetPremiumPackages _getPackages;
  final PurchasePremium _purchase;
  final RestorePurchases _restore;
  final WatchPremiumStatus _watch;
  final SetDebugPremium _setDebugPremium;
  final IsStoreAvailable _isStoreAvailable;

  bool _starting = false;

  StreamSubscription<dynamic>? _subscription;

  Future<void> _onStarted(
    PremiumStarted event,
    Emitter<PremiumState> emit,
  ) async {
    if (_starting) return;
    _starting = true;
    try {
      emit(state.copyWith(packagesLoading: true, loadFailed: false));
      // Errors on the stream are ignored by design.
      await _subscription?.cancel();
      _subscription = _watch().listen(
        (status) => add(PremiumStatusPushed(status)),
        onError: (Object _) {},
      );
      var failed = false;
      final status = await _getStatus();
      status.fold(
        (_) {
          failed = true;
          // The store is still the store when a read fails.
          emit(state.copyWith(
            status: state.status.copyWith(storeAvailable: _isStoreAvailable()),
          ));
        },
        (s) => emit(state.copyWith(status: s)),
      );
      final packages = await _getPackages();
      packages.fold(
        (_) => emit(state.copyWith(packagesLoading: false, loadFailed: true)),
        (list) => emit(state.copyWith(
          packages: list,
          packagesLoading: false,
          loadFailed: failed,
        )),
      );
    } finally {
      _starting = false;
    }
  }

  Future<void> _onPurchase(
    PremiumPurchaseRequested event,
    Emitter<PremiumState> emit,
  ) async {
    if (state.busy != PremiumBusy.none) return;
    emit(state.copyWith(busy: PremiumBusy.purchasing, message: null));
    final result = await _purchase(event.packageId);
    result.fold(
      (failure) => emit(state.copyWith(
        busy: PremiumBusy.none,
        message: failure is PurchaseCancelledFailure ? null : failure.message,
      )),
      (status) => emit(state.copyWith(
        busy: PremiumBusy.none,
        status: status,
        message: status.isPremium ? 'Welcome to Premium!' : null,
      )),
    );
  }

  Future<void> _onRestore(
    PremiumRestoreRequested event,
    Emitter<PremiumState> emit,
  ) async {
    if (state.busy != PremiumBusy.none) return;
    emit(state.copyWith(busy: PremiumBusy.restoring, message: null));
    final result = await _restore();
    result.fold(
      (failure) => emit(
        state.copyWith(busy: PremiumBusy.none, message: failure.message),
      ),
      (status) => emit(state.copyWith(
        busy: PremiumBusy.none,
        status: status,
        message: status.isPremium
            ? 'Purchases restored'
            : 'No previous purchases found',
      )),
    );
  }

  void _onDebugToggled(
    PremiumDebugToggled event,
    Emitter<PremiumState> emit,
  ) {
    if (!kDebugMode) return;
    _setDebugPremium(event.enabled);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
