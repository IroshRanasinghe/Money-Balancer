import 'package:equatable/equatable.dart';

import '../../domain/entities/export_target.dart';

sealed class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class BackupExportRequested extends BackupEvent {
  const BackupExportRequested();
}

class BackupRestoreRequested extends BackupEvent {
  const BackupRestoreRequested();
}

class CsvExportRequested extends BackupEvent {
  const CsvExportRequested(this.target);

  final ExportTarget target;

  @override
  List<Object?> get props => [target];
}
