import 'dart:io';

import 'package:app_installer_plus/core/apiServices/helper/app_helper.dart';
import 'package:path_provider/path_provider.dart';

import 'app_installer_plus_platform_interface.dart';

class AppInstallerPlus {
  /// Downloads an APK from the given URL and installs it automatically on Android devices.
  /// This method also provides a download progress callback and error handling
  Future<void> downloadAndInstallApk({
    required String downloadFileUrl,
    void Function(String error)? onError,
    void Function(double progress)? onProgress,
    String? downloadFileName,
  }) async {
    await AppInstallerPlusPlatform.instance.downloadAndInstallApk(
      downloadFileUrl: downloadFileUrl,
      onError: onError,
      onProgress: onProgress,
      downloadFileName: downloadFileName,
    );
  }

  /// This method used to delete the downloaded apk if not needed
  /// It return true, if it successfully deleted. or else false will be returned
  Future<bool> removedDownloadedApk({String? downloadFileName}) async {
    try {
      Directory? downloadDirectory = await getExternalStorageDirectory();
      if (downloadDirectory == null) return false;

      String apkPath =
          "${downloadDirectory.path}/${downloadFileName ?? 'downloadApk'}.apk";

      File file = File(apkPath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e, sc) {
      printLog(e, stackTrace: sc);
      return false;
    }
    return false;
  }
}
