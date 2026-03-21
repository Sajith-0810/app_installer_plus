# 🚀 app_installer_plus

A robust, production-ready Flutter plugin to **download and safely install APKs** on Android devices. Ideal for handling seamless in-app updates or installing APKs directly from a URL.

> ✅ **Android-only** | 📦 **FileProvider Integration** | 🛡️ **Leak-Proof Memory Management**

---

## ✨ Features

* 📥 **Direct URL Downloads:** Fetch APKs from any direct web URL.
* 📊 **Granular Metrics:** Track real-time progress, download speed, time remaining, and byte sizes.
* 🛡️ **Concurrency Protection:** Automatically prevents users from accidentally starting duplicate downloads.
* 🧹 **Smart Auto-Cleanup [NEW]:** Option to automatically delete corrupted/partial files if a network error occurs (`deleteOnError`).
* 🛑 **Advanced Cancellation [NEW]:** Cancel active downloads and optionally wipe the partial file from storage (`deletePartialDownload`).
* 🚨 **Modern Error Handling [NEW]:** Catch specific failure states using `FileDownloadException` and `DownloadErrorType`.

---

## Android Configuration

**1. Add this to your AndroidManifest.xml inside the `<application>` tag :**
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

**2. Create a file named `file_paths.xml` inside the `android/app/src/main/res/xml/` folder:**
```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
    <files-path name="files" path="."/>
</paths>
```

**3. Add Permission**
- In `android/app/src/main/AndroidManifest.xml`, add these permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

## Code Example

**1. Apk Update**

```dart
import 'package:app_installer_plus/app_installer_plus.dart';

Future<void> updateApp() async {
  try {
    await AppInstallerPlus().downloadAndInstallApk(
      downloadFileUrl: "https://www.example.com/myapp.apk",
      deleteOnError: true, // Automatically deletes partial file if network fails
      onProgress: (progress) {
        print("Download Progress: ${(progress * 100).toStringAsFixed(0)}%");
      },
      onDownloadedSize: (downloadedSize) => print("Downloaded: $downloadedSize"),
      onTotalSize: (totalSize) => print("Total Size: $totalSize"),
      onSpeed: (speed) => print("Speed: $speed"),
      onTimeLeft: (timeLeft) => print("Time Left: $timeLeft"),
    );
  } on FileDownloadException catch (e) {
    if (e.type == DownloadErrorType.alreadyRunning) {
      print("A download is already in progress!");
    } else {
      print("Download failed: ${e.originalError}");
    }
  }
}
```

**2. Delete the downloaded apk**
```dart
  await AppInstallerPlus().removedDownloadedApk();
```
- Remove the downloaded apk once the process completed


**3. Cancel the download request**
```dart
// Cancels the download and permanently wipes the incomplete file from storage
await AppInstallerPlus().cancelDownload(deletePartialDownload: true);
```
- Stops an active APK download before it finishes.


## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  app_installer_plus: ^1.2.0
```