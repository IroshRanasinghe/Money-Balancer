import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/bank_card.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/get_card_spending.dart';
import '../../domain/usecases/save_card.dart';
import 'cards_event.dart';
import 'cards_state.dart';

export 'cards_event.dart';
export 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  CardsBloc(
    this._getCardSpending,
    this._saveCard,
    this._deleteCard,
    this._uuid,
  ) : super(const CardsState()) {
    on<CardsLoadRequested>((e, emit) => _load(emit));
    on<CardSaveRequested>(_onSave);
    on<CardDeleteRequested>(_onDelete);
  }

  final GetCardSpending _getCardSpending;
  final SaveCard _saveCard;
  final DeleteCard _deleteCard;
  final Uuid _uuid;

  Future<void> _load(Emitter<CardsState> emit) async {
    emit(state.copyWith(status: CardsStatus.loading, errorMessage: null));
    final now = DateTime.now();
    final result = await _getCardSpending(month: now.month, year: now.year);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CardsStatus.failure,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: CardsStatus.success,
        items: items,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSave(
      CardSaveRequested event, Emitter<CardsState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final nickname = event.nickname.trim();
    if (nickname.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a card nickname'));
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(event.last4)) {
      emit(state.copyWith(errorMessage: 'Enter the last 4 digits'));
      return;
    }
    final now = DateTime.now();
    final validExpiry = event.expiryMonth >= 1 &&
        event.expiryMonth <= 12 &&
        event.expiryYear >= now.year &&
        event.expiryYear <= now.year + 20 &&
        DateTime(event.expiryYear, event.expiryMonth + 1).isAfter(now);
    if (!validExpiry) {
      emit(state.copyWith(errorMessage: 'Enter a valid expiry date'));
      return;
    }
    final result = await _saveCard(BankCard(
      id: event.id ?? _uuid.v4(),
      nickname: nickname,
      bankName: event.bankName.trim(),
      type: event.type,
      network: event.network,
      last4: event.last4,
      expiryMonth: event.expiryMonth,
      expiryYear: event.expiryYear,
      colorValue: event.colorValue,
      createdAt: event.createdAt ?? now,
    ));
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _load(emit),
    );
  }

  Future<void> _onDelete(
      CardDeleteRequested event, Emitter<CardsState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final result = await _deleteCard(event.id);
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _load(emit),
    );
  }
}
