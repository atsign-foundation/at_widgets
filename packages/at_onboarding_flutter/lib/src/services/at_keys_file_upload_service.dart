import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/at_onboarding_services.dart';
import 'package:at_onboarding_flutter/src/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/src/utils/at_onboarding_response_status.dart';
import 'package:at_utils/at_logger.dart';
import 'package:file_picker/file_picker.dart';

class AtKeysFileUploadService {
  final AtSignLogger _logger = AtSignLogger('At Onboarding');
  late final OnboardingService _onboardingService;
  final AtOnboardingConfig _config;
  AtKeysFileUploadService({required AtOnboardingConfig config})
      : _config = config {
    _onboardingService = OnboardingService.getInstance();
    _onboardingService.setAtClientPreference = _config.atClientPreference;
  }

  bool get isMobile => Platform.isIOS || Platform.isAndroid;
  Future<String?> pickFile() async {
    try {
      FilePickerResult? result = isMobile
          ? await FilePicker.platform.pickFiles(
              type: FileType.any,
            )
          : await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['atKeys', 'atkeys'],
            );

      return result?.files.single.path;
    } catch (e) {
      _logger.severe('Error with desktop atKeys file picker: $e');
      return null;
    }
  }

  Stream<FileUploadStatus> uploadKeyFile(String? pairingAtsign) {
    final StreamController<FileUploadStatus> streamController =
        StreamController();
    _uploadKeyFileForDesktop(streamController, pairingAtsign);
    return streamController.stream;
  }

  Future<void> _uploadKeyFileForDesktop(
      StreamController<FileUploadStatus> streamController,
      String? pairingAtsign) async {
    try {
      String? fileContents, aesKey, atsign;
      streamController.add(const FilePickingInProgress());

      String? path = await pickFile();
      if (path == null) {
        streamController.add(const FilePickingCanceled());
        return;
      }

      File selectedFile = File(path);
      int length = selectedFile.lengthSync();
      if (length < 10) {
        streamController.add(const ErrorIncorrectKeyFile());
        return;
      }

      fileContents = File(path).readAsStringSync();
      if (!_validatePickedFileContents(fileContents)) {
        streamController.add(const ErrorIncorrectKeyFile());
        return;
      }
      if (fileContents.isNotEmpty) {
        List<String> keyData = fileContents.split(',"@');
        List<String> params = keyData[1]
            .toString()
            .substring(0, keyData[1].length - 2)
            .split('":"');
        atsign = "@${params[0]}";
        Map<String, dynamic> keyMap = jsonDecode(fileContents);
        aesKey = keyMap[AtOnboardingConstants.atSelfEncryptionKey];
      }
      if (fileContents.isEmpty || (aesKey == null && atsign == null)) {
        streamController.add(const ErrorIncorrectKeyFile());
        return;
      } else if (OnboardingService.getInstance().formatAtSign(atsign) !=
              pairingAtsign &&
          pairingAtsign != null) {
        streamController.add(const ErrorAtSignMismatch());
        return;
      }

      streamController.add(const FilePickingDone());
      await _processAESKey(atsign, aesKey, fileContents, streamController);
    } catch (error) {
      _logger.severe('Uploading backup zip file throws $error');
      streamController.add(const ErrorFailedFileProcessing());
    }
  }

  Future<void> _processAESKey(String? atsign, String? aesKey, String contents,
      StreamController<FileUploadStatus>? controller,
      {bool retry = true}) async {
    dynamic authResponse;
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != '');
    controller?.add(const ProcessingAesKeyInProgress());
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      bool isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        controller?.add(const ProcessingAesKeyDone());
        controller?.add(ErrorPairedAtsign(atsign));
        return;
      }

      _onboardingService.setAtClientPreference = _config.atClientPreference;

      authResponse = await _onboardingService.authenticate(
        atsign,
        jsonData: contents,
        decryptKey: aesKey,
      );
      controller?.add(const ProcessingAesKeyDone());
      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        controller?.add(FileUploadAuthSuccess(atsign));
      } else if (authResponse == AtOnboardingResponseStatus.serverNotReached) {
        controller?.add(const ErrorAtServerUnreachable());
      } else if (authResponse == AtOnboardingResponseStatus.authFailed) {
        controller?.add(const ErrorAuthFailed());
      } else {}
    } catch (e) {
      controller?.add(const ProcessingAesKeyDone());
      if (e == AtOnboardingResponseStatus.serverNotReached && retry) {
        await _processAESKey(atsign, aesKey, contents, controller,
            retry: false);
      } else if (e == AtOnboardingResponseStatus.authFailed) {
        _logger.severe('Error in authenticateWithAESKey');
        controller?.add(const ErrorAuthFailed());
      } else if (e == AtOnboardingResponseStatus.timeOut) {
        controller?.add(const ErrorAuthTimeout());
      } else {
        _logger.warning(e);
      }
    }
  }

  bool _validatePickedFileContents(String fileContents) {
    bool result = fileContents
            .contains(BackupKeyConstants.PKAM_PRIVATE_KEY_FROM_KEY_FILE) &&
        fileContents
            .contains(BackupKeyConstants.PKAM_PUBLIC_KEY_FROM_KEY_FILE) &&
        fileContents
            .contains(BackupKeyConstants.ENCRYPTION_PRIVATE_KEY_FROM_FILE) &&
        fileContents
            .contains(BackupKeyConstants.ENCRYPTION_PUBLIC_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.SELF_ENCRYPTION_KEY_FROM_FILE);
    return result;
  }
}

sealed class FileUploadStatus {
  const FileUploadStatus();
}

// Errors

class ErrorIncorrectKeyFile extends FileUploadStatus {
  const ErrorIncorrectKeyFile();
}

class ErrorAtSignMismatch extends FileUploadStatus {
  const ErrorAtSignMismatch();
}

class ErrorFailedFileProcessing extends FileUploadStatus {
  const ErrorFailedFileProcessing();
}

class ErrorAtServerUnreachable extends FileUploadStatus {
  const ErrorAtServerUnreachable();
}

class ErrorAuthFailed extends FileUploadStatus {
  const ErrorAuthFailed();
}

class ErrorAuthTimeout extends FileUploadStatus {
  const ErrorAuthTimeout();
}

class ErrorPairedAtsign extends FileUploadStatus {
  final String? atSign;
  ErrorPairedAtsign(this.atSign);
}

// File Picking

class FilePickingInProgress extends FileUploadStatus {
  const FilePickingInProgress();
}

class FilePickingDone extends FileUploadStatus {
  const FilePickingDone();
}

class FilePickingCanceled extends FileUploadStatus {
  const FilePickingCanceled();
}

// Processing AesKey

class ProcessingAesKeyInProgress extends FileUploadStatus {
  const ProcessingAesKeyInProgress();
}

class ProcessingAesKeyDone extends FileUploadStatus {
  const ProcessingAesKeyDone();
}

class FileUploadAuthSuccess extends FileUploadStatus {
  final String? atSign;
  FileUploadAuthSuccess(this.atSign);
}
