import 'package:equatable/equatable.dart';

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
  const CsvExportRequested();
}
