# 🔄 app_installer_plus

A Flutter plugin to **download and install APKs** on Android. Ideal for in-app updates or installing APKs from a URL.

> ✅ Android-only | 📦 Installs APKs using FileProvider | 📊 Download progress support

---

## ✨ Features

- Download APK from any direct URL
- Show download progress
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
- In `android/app/src/main/AndroidManifest.xml`, add these permission:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

## Code Example

**1. Apk Update**

```dart
await AppInstallerPlus().downloadAndInstallApk(
    downloadFileUrl: "https://www.example.com/myapp.apk",
    onError: (error) {
      // show the error message here
    },
    onProgress: (progress) {
      // handle the progress here
      },
);
```

- `downloadFileUrl`
    - **Type:** `String`
    - **Description:** Direct URL of the APK file to download and install.

- `onError`
    - **Type:** `Function(String error)`
    - **Description:** Callback triggered when an error occurs.

- `onProgress`
    - **Type:** `Function(double progress)`
    - **Description:**
        - Tracks real-time download progress.
        - Value ranges from `0.0` to `1.0` (e.g., `0.5 = 50%`).

**2. Delete the downloaded apk**
```dart
  await AppInstallerPlus().removedDownloadedApk()
```
- Remove the downloaded apk once the process completed


## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  app_installer_plus: ^1.0.1
