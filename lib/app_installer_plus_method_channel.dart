import 'package:app_installer_plus/core/apiServices/api_service.dart';
import 'package:app_installer_plus/core/exceptions/file_download_exception.dart';
import 'package:app_installer_plus/core/enums/download_error_type.dart';
import 'package:app_installer_plus/core/helper/app_helper.dart';
import 'package:flutter/services.dart';

import 'app_installer_plus_platform_interface.dart';

/// An implementation of [AppInstallerPlusPlatform] that uses method channels.
class MethodChannelAppInstallerPlus extends AppInstallerPlusPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel _channel = const MethodChannel('app_installer_plus');

  @override
  Future<void> downloadAndInstallApk({
    required String downloadFileUrl,

    @Deprecated('Use try-catch with FileDownloadException instead. This will be removed in v2.0.0.')
    void Function(String error)? onError,

    void Function(double progress)? onProgress,
    String? downloadFileName,
  }) async {
    try {
      if (downloadFileUrl.trim().isEmpty) {
        throw ArgumentError("Download File Url cannot be empty");
      }

      // 1. Await ApiService directly. Do NOT pass onSuccess/onError here anymore.
      // Let ApiService throw the Exception naturally.
      String? filePath = await ApiService().downloadFile(
        downloadFileUrl: downloadFileUrl,
        downloadFileName: downloadFileName,
        onProgress: onProgress,
      );

      // 2. If successful, trigger the native installation
      if (filePath != null) {
        await _channel.invokeMethod<String>('downloadAndInstallApk', {"path": filePath});
      }
    } on FileDownloadException catch (e, sc) {
      printLog(e.toString(), stackTrace: sc);
      _handleErrorBridge(e, "Error occurred during download", onError);
    } on PlatformException catch (e, sc) {
      printLog(e.toString(), stackTrace: sc);
      final exception = FileDownloadException(type: DownloadErrorType.unknown, originalError: e);
      _handleErrorBridge(exception, e.message ?? "Platform Exception occurred", onError);
    } catch (e, sc) {
      printLog(e.toString(), stackTrace: sc);
      final exception = FileDownloadException(type: DownloadErrorType.unknown, originalError: e);
      _handleErrorBridge(exception, e.toString(), onError);
    }
  }

  /// A private helper to route the error to the legacy callback OR throw it
  void _handleErrorBridge(
    FileDownloadException exception,
    String legacyMessage,
    void Function(String)? onErrorCallback,
  ) {
    if (onErrorCallback != null) {
      // Legacy Mode: The user provided the old callback. Send them the string.
      onErrorCallback(legacyMessage);
    } else {
      // Modern Mode: The user wants to use try-catch. Throw the exception!
      throw exception;
    }
  }
}
