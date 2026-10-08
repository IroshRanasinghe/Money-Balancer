import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/exceptions.dart';

abstract class BackupFileDataSource {
  Future<void> shareFile({
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
  Future<void> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(utf8.encode(content),
              mimeType: mimeType, name: fileName),
        ],
        fileNameOverrides: [fileName],
      ));
    } catch (_) {
      throw const FileException();
    }
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
