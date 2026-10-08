import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  /// Returns stored settings, or defaults when nothing is stored yet.
  Future<Either<Failure, AppSettings>> getSettings();

  Future<Either<Failure, void>> saveSettings(AppSettings settings);
}
