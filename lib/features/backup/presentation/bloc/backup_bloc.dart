import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/export_target.dart';
import '../../domain/usecases/export_backup.dart';
import '../../domain/usecases/export_transactions_csv.dart';
import '../../domain/usecases/restore_backup_from_file.dart';
import 'backup_event.dart';
import 'backup_state.dart';

export '../../domain/entities/export_target.dart';
export 'backup_event.dart';
export 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  BackupBloc(this._exportBackup, this._restoreBackup, this._exportCsv)
    : super(const BackupState()) {
    on<BackupExportRequested>(_onExport);
    on<BackupRestoreRequested>(_onRestore);
    on<CsvExportRequested>(_onCsv);
  }

  final ExportBackup _exportBackup;
  final RestoreBackupFromFile _restoreBackup;
  final ExportTransactionsCsv _exportCsv;

  Future<void> _onExport(
    BackupExportRequested event,
    Emitter<BackupState> emit,
  ) async {
    if (state.status == BackupStatus.working) return;
    emit(state.copyWith(status: BackupStatus.working, message: null));
    _emitDone(
      await _exportBackup(DateTime.now()),
      'Backup ready to save',
      emit,
    );
  }

  Future<void> _onCsv(
    CsvExportRequested event,
    Emitter<BackupState> emit,
  ) async {
    if (state.status == BackupStatus.working) return;
    emit(state.copyWith(status: BackupStatus.working, message: null));
    _emitDone(
      await _exportCsv(DateTime.now(), event.target),
      event.target == ExportTarget.device
          ? 'Transactions saved to device'
          : 'Transactions exported',
      emit,
    );
  }

  Future<void> _onRestore(
    BackupRestoreRequested event,
    Emitter<BackupState> emit,
  ) async {
    if (state.status == BackupStatus.working) return;
    emit(state.copyWith(status: BackupStatus.working, message: null));
    final result = await _restoreBackup();
    result.fold(
      (failure) => emit(
        state.copyWith(status: BackupStatus.failure, message: failure.message),
      ),
      (counts) {
        if (counts == null) {
          emit(state.copyWith(status: BackupStatus.idle, message: null));
          return;
        }
        emit(
          state.copyWith(
            status: BackupStatus.success,
            message: 'Restored ${counts.transactions} transactions',
            restoredCount: state.restoredCount + 1,
          ),
        );
      },
    );
  }

  void _emitDone(
    Either<Failure, bool> result,
    String successMessage,
    Emitter<BackupState> emit,
  ) {
    result.fold(
      (failure) => emit(
        failure is PremiumRequiredFailure
            ? state.copyWith(
                status: BackupStatus.idle,
                message: null,
                paywallCount: state.paywallCount + 1,
                paywallFeature: failure.feature,
              )
            : state.copyWith(
                status: BackupStatus.failure,
                message: failure.message,
              ),
      ),
      (shared) => emit(
        shared
            ? state.copyWith(
                status: BackupStatus.success,
                message: successMessage,
              )
            : state.copyWith(status: BackupStatus.idle, message: null),
      ),
    );
  }
}
