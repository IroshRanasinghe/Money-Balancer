import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/card_number.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/get_card_number.dart';
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
    this._getCardNumber,
    this._uuid,
  ) : super(const CardsState()) {
    on<CardsLoadRequested>((e, emit) => _load(emit));
    on<CardSaveRequested>(_onSave);
    on<CardDeleteRequested>(_onDelete);
    on<CardNumberRevealRequested>(_onReveal);
    on<CardNumberRevealDismissed>((e, emit) => emit(state.copyWith(
        revealedCardId: null, revealedNumber: null)));
  }

  final GetCardSpending _getCardSpending;
  final SaveCard _saveCard;
  final DeleteCard _deleteCard;
  final GetCardNumber _getCardNumber;
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
    final number = digitsOnly(event.cardNumber);
    String last4;
    String? numberToStore;
    final existingLast4 = event.existingLast4;
    if (number.isEmpty && event.id != null && existingLast4 != null) {
      last4 = existingLast4;
    } else {
      if (!isValidCardNumber(number)) {
        emit(state.copyWith(errorMessage: 'Enter a valid card number'));
        return;
      }
      last4 = number.substring(number.length - 4);
      numberToStore = number;
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
      last4: last4,
      expiryMonth: event.expiryMonth,
      expiryYear: event.expiryYear,
      colorValue: event.colorValue,
      createdAt: event.createdAt ?? now,
    ), cardNumber: numberToStore);
    await result.fold(
      (failure) async {
        emit(failure is PremiumRequiredFailure
            ? state.copyWith(
                paywallCount: state.paywallCount + 1,
                paywallFeature: failure.feature,
              )
            : state.copyWith(errorMessage: failure.message));
        await _load(emit);
      },
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

  Future<void> _onReveal(
      CardNumberRevealRequested event, Emitter<CardsState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final result = await _getCardNumber(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (number) => number == null
          ? emit(state.copyWith(
              errorMessage: 'Full number not saved for this card'))
          : emit(state.copyWith(
              revealedCardId: event.id, revealedNumber: number)),
    );
  }
}
