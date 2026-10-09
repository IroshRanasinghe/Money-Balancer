import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/exceptions.dart';

abstract class BackupFileDataSource {
  /// False when the user dismisses the share sheet.
  Future<bool> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
  });

  /// False when the user cancels the "Save as" picker.
  Future<bool> saveFile({
    required String fileName,
    required String content,
    required String mimeType,
  });

  /// Null when the user cancels.
  Future<String?> pickTextFile({required List<String> extensions});
}

class PlatformBackupFileDataSource implements BackupFileDataSource {
  const PlatformBackupFileDataSource();

  @override
  Future<bool> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              utf8.encode(content),
              mimeType: mimeType,
              name: fileName,
            ),
          ],
          fileNameOverrides: [fileName],
          sharePositionOrigin: _screenCentre(),
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    } catch (_) {
      throw const FileException();
    }
  }

  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      final uri = await FilePicker.saveFile(
        fileName: fileName,
        bytes: utf8.encode(content),
        mimeType: mimeType,
      );
      return uri != null;
    } catch (_) {
      throw const FileException();
    }
  }

  /// iPad presents the share sheet as a popover and fails without an anchor.
  Rect _screenCentre() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: 1,
      height: 1,
    );
  }

  @override
  Future<String?> pickTextFile({required List<String> extensions}) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: extensions,
      );
      if (file == null) return null;
      return utf8.decode(await file.readAsBytes());
    } catch (_) {
      throw const FileException();
    }
  }
}
