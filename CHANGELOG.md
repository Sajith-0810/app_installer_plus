## 1.2.0

**✨ New Features:**
* **Auto-Cleanup on Error:** Added the `deleteOnError` parameter to `downloadAndInstallApk`. When set to `true`, the package will automatically delete incomplete APK files if the download fails due to a network or server error.
* **Smart Cancellation:** Added the `deletePartialDownload` parameter to `cancelDownload`. This gives developers explicit control to permanently delete the partial file when a user cancels an active download.

**🛡️ Stability & Core Improvements:**
* **Concurrency Lock:** Added bulletproof protection against concurrent downloads. Attempting to start a download while one is already active will now safely throw a `DownloadErrorType.alreadyRunning` exception instead of corrupting the file state.
* **Storage Safety:** Fixed an asynchronous race condition to guarantee orphaned or junk files are never left behind on the user's device after cancellations or unexpected HTTP status codes.
* **Complete Documentation:** Added comprehensive, pub.dev-compliant Dartdoc comments to all public classes, methods, and parameters for improved IDE Intellisense and perfect package scoring.

## 1.1.0

**✨ New Features:**
* **Cancel Download:** Added a new method to cancel an ongoing download request.
* **Granular Progress Metrics:** Added new callback parameters to `downloadAndInstallApk` for detailed UI updates:
  * `onTimeLeft`: Returns the estimated time remaining.
  * `onSpeed`: Returns the current download speed.
  * `onTotalSize`: Returns the total size of the file.
  * `onDownloadedSize`: Returns the currently downloaded file size.

**⚠️ Deprecations & Updates:**
* **`onError` is Deprecated:** You can still use the `onError` callback for now, and it will function without any issues. However, it is highly recommended to wrap your method call in a `try-catch` block to catch the new `FileDownloadException` instead.
* **Future Removal:** Catching the exception is the better approach for handling custom error messages, and the `onError` callback will be completely removed in future versions.

## 1.0.1
- Added GitHub repository link.

## 1.0.0
- Initial release of `app_installer_plus`.
- Support for downloading APK files from a direct URL.
- Progress tracking using `onProgress` callback.
- Secure APK installation using Android FileProvider.
- Example app demonstrating usage.