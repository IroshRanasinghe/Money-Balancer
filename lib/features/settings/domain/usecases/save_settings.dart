import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(AppSettings settings) =>
      _repository.saveSettings(settings);
}
