import 'package:equatable/equatable.dart';

sealed class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object?> get props => [];
}

class AccountDetailLoadRequested extends AccountDetailEvent {
  const AccountDetailLoadRequested(this.accountId);
  final String accountId;

  @override
  List<Object?> get props => [accountId];
}
