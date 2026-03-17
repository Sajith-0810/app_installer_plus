import 'package:app_installer_plus/app_installer_plus.dart';
import 'package:app_installer_plus/core/enums/download_error_type.dart';
import 'package:app_installer_plus/core/exceptions/file_download_exception.dart';
import 'package:app_installer_plus/core/helper/app_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _urlController = TextEditingController();
  double downloadPercent = 0;

  final OutlineInputBorder _border = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Colors.black),
  );

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Bg Color
      backgroundColor: Colors.white,

      /// App Bar
      appBar: AppBar(title: const Text("App Update Example"), centerTitle: true),

      /// Body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Url Text Form Filed
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: "Paste your download file URL here",
                  border: _border,
                  enabledBorder: _border,
                  focusedBorder: _border,
                  hintFadeDuration: const Duration(milliseconds: 350),
                ),
              ),
            ),

            /// Progress Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: downloadPercent,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 5,
                    strokeAlign: 4,
                    backgroundColor: Colors.grey.shade100,
                  ),
                  Text("${(downloadPercent * 100).toStringAsFixed(0)}%"),
                ],
              ),
            ),

            /// Download and Install Button and Remove APK Button
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0).copyWith(top: 15),
                    child: FilledButton(
                      onPressed: () async {
                        if (_urlController.text.trim().isEmpty) {
                          showSnackBar(message: "Url is mandatory");
                          return;
                        }
                        await onDownloadClicked();
                      },
                      child: const Text("Download & Install"),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FilledButton(
                      onPressed: () async {
                        bool isDeleted = await AppInstallerPlus().removedDownloadedApk();
                        if (isDeleted) {
                          showSnackBar(message: "Deleted Successfully");
                        } else {
                          showSnackBar(message: "Deleted UnSuccessfully");
                        }
                      },
                      child: const Text("Delete Apk"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDownloadClicked() async {
    try {
      await AppInstallerPlus().downloadAndInstallApk(
        downloadFileUrl: _urlController.text,
        downloadFileName: "test",
        onDownloadSize: (size) {
          printLog("File Size: $size bytes");
        },
        onSpeed: (speed) {
          printLog("Download Speed: $speed bytes/s");
        },
        onTimeLeft: (timeLeft) {
          printLog("Estimated Time Left: $timeLeft seconds");
        },
        onProgress: (progress) {
          setState(() {
            downloadPercent = progress;
          });
        },
      );
    } on FileDownloadException catch (e) {
      switch (e.type) {
        case DownloadErrorType.cancelled:
          showSnackBar(message: "Request Cancelled");
          break;
        case DownloadErrorType.storageAccessDenied:
          showSnackBar(message: "Storage access denied. Please grant permissions and try again.");
          break;
        case DownloadErrorType.badResponse:
          showSnackBar(message: "bad response from server. Please check the URL and try again.");
          break;
        case DownloadErrorType.networkTimeout:
          showSnackBar(message: "Timeout. Please check your internet connection and try again.");
          break;
        case DownloadErrorType.noInternetConnection:
          showSnackBar(message: "No internet connection. Please check your connection and try again.");
          break;
        case DownloadErrorType.unknown:
          showSnackBar(message: "An unknown error occurred. Please try again.");
          break;
      }
    } catch (e) {
      showSnackBar(message: "An error occurred: $e");
    }
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
