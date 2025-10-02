import 'package:app_installer_plus/core/apiServices/api_service.dart';
import 'package:app_installer_plus/core/apiServices/helper/app_helper.dart';
import 'package:flutter/services.dart';

import 'app_installer_plus_platform_interface.dart';

/// An implementation of [AppInstallerPlusPlatform] that uses method channels.
class MethodChannelAppInstallerPlus extends AppInstallerPlusPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel _channel = const MethodChannel('app_installer_plus');

  @override
  Future<void> downloadAndInstallApk({
    required String downloadFileUrl,
    void Function(String error)? onError,
    void Function(double progress)? onProgress,
    String? downloadFileName,
  }) async {
    try {
      if (downloadFileUrl.trim().isEmpty) {
        onError?.call("Download File Url is empty");
        return;
      }

      await ApiService().downloadFile(
        downloadFileUrl: downloadFileUrl,
        downloadFileName: downloadFileName,
        onSuccess: (filePath) async {
          await _channel.invokeMethod<String>('downloadAndInstallApk', {
            "path": filePath,
          });
        },
        onError: (error) {
          onError?.call(error);
        },
        onProgress: (progress) {
          onProgress?.call(progress);
        },
      );
    } on PlatformException catch (e, sc) {
      printLog(e.toString(), stackTrace: sc);
      if (onError != null) {
        onError(e.message ?? "");
      }
    } catch (e, sc) {
      printLog(e.toString(), stackTrace: sc);
      onError?.call(e.toString());
    }
  }
}
