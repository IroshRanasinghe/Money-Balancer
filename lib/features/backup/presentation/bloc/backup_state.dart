import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_state.freezed.dart';

enum BackupStatus { idle, working, success, failure }

@freezed
abstract class BackupState with _$BackupState {
  const factory BackupState({
    @Default(BackupStatus.idle) BackupStatus status,
    String? message,
    @Default(0) int restoredCount,
  }) = _BackupState;
}
