import 'package:equatable/equatable.dart';

sealed class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class ReportsLoadRequested extends ReportsEvent {
  const ReportsLoadRequested();
}

class ReportsMonthShifted extends ReportsEvent {
  const ReportsMonthShifted(this.delta);
  final int delta;
  @override
  List<Object?> get props => [delta];
}
