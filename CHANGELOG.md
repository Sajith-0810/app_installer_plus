## 1.0.0
- Initial release of `app_installer_plus`.
- Support for downloading APK files from a direct URL.
- Progress tracking using `onProgress` callback.
- Secure APK installation using Android FileProvider.
- Example app demonstrating usage.

## 1.0.1
- Added GitHub repository link.

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