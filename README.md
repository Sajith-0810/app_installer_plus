# 🔄 app_installer_plus

A Flutter plugin to **download and install APKs** on Android. Ideal for in-app updates or installing APKs from a URL.

> ✅ Android-only | 📦 Installs APKs using FileProvider | 📊 Download progress support

---

## ✨ Features

- Download APK from any direct URL
- Show real-time download progress
- **[NEW]** Track downloaded size and total file size
- **[NEW]** Track live download speed and estimated time left
- **[NEW]** Cancel ongoing downloads
- Automatically install the APK
- Uses Android FileProvider to handle secure file access

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
await AppInstallerPlus().downloadAndInstallApk(
    downloadFileUrl: "https://www.example.com/myapp.apk",
    onProgress: (progress) {
      // handle the progress here
      },
    onDownloadedSize: (downloadedSize) {
      // handle the downloaded size here
      },
    onTotalSize: (totalSize) {
      // handle the total size here
      },
    onSpeed: (speed) {
      // handle the download speed here
      },
    onTimeLeft: (timeLeft) {
      // handle the estimated time left here
      },
);
```

**2. Delete the downloaded apk**
```dart
  await AppInstallerPlus().removedDownloadedApk();
```
- Remove the downloaded apk once the process completed


**3. Cancel the download request**
```dart
  AppInstallerPlus().cancelDownload();
```
- Stops an active APK download before it finishes.


## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  app_installer_plus: ^1.1.0
