import 'dart:developer';
import 'dart:io';

import 'package:app_installer_plus/core/enums/download_error_type.dart';
import 'package:app_installer_plus/core/exceptions/file_download_exception.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  CancelToken? _cancelToken;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() : _dio = Dio();

  Future<String?> downloadFile({
    required String downloadFileUrl,
    void Function(double progress)? onProgress,
    @Deprecated('Use a try-catch block to handle FileDownloadException instead.') void Function(String error)? onError,
    void Function(String timeLeft)? onTimeLeft,
    void Function(String speed)? onSpeed,
    void Function(String totalSize)? onTotalSize,
    void Function(String downloadedSize)? onDownloadedSize,
    String? downloadFileName,
  }) async {
    _cancelToken = CancelToken();

    int lastBytes = 0;
    DateTime lastUpdateTime = DateTime.now();

    try {
      Directory? directory = await getExternalStorageDirectory();

      if (directory == null) {
        final exception = FileDownloadException(
          type: DownloadErrorType.storageAccessDenied,
          originalError: "Unable to access storage directory",
        );
        return _handleErrorBridge(exception, "Unable to access storage directory", onError);
      }

      String savePath = "${directory.path}/${downloadFileName ?? "downloadApk"}.apk";

      Response response = await _dio.download(
        downloadFileUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            if (onProgress != null) {
              onProgress(count / total);
            }

            if (onTotalSize != null) {
              onTotalSize(_formatBytes(total));
            }

            if (onDownloadedSize != null) {
              onDownloadedSize(_formatBytes(count));
            }

            DateTime now = DateTime.now();
            Duration interval = now.difference(lastUpdateTime);

            // Update speed and time left every 500ms or when finished
            if (interval.inMilliseconds >= 500 || count == total) {
              int bytesSinceLast = count - lastBytes;
              double secondsSinceLast = interval.inMilliseconds / 1000.0;

              if (secondsSinceLast > 0) {
                double speedBps = bytesSinceLast / secondsSinceLast;

                if (onSpeed != null) {
                  onSpeed(_formatSpeed(speedBps));
                }

                if (onTimeLeft != null && speedBps > 0) {
                  double remainingBytes = (total - count).toDouble();
                  double remainingSeconds = remainingBytes / speedBps;
                  onTimeLeft(_formatTimeLeft(remainingSeconds));
                }
              }

              lastBytes = count;
              lastUpdateTime = now;
            }
          }
        },
      );

      if (response.statusCode == 200) {
        return savePath;
      } else {
        final exception = FileDownloadException(
          type: DownloadErrorType.badResponse,
          statusCode: response.statusCode,
          originalError: "Server returned status: ${response.statusCode}",
        );
        return _handleErrorBridge(exception, "Unable to download the file", onError);
      }
    } on DioException catch (e, sc) {
      log("DioException in downloadFile", error: e, stackTrace: sc);
      final exception = FileDownloadException(
        type: _mapDioErrorToEnum(e.type),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
      String legacyErrorString = _getLegacyErrorMessage(e);
      return _handleErrorBridge(exception, legacyErrorString, onError);
    } catch (e, sc) {
      log("Unknown Exception in downloadFile", error: e, stackTrace: sc);
      final exception = FileDownloadException(type: DownloadErrorType.unknown, originalError: e);
      return _handleErrorBridge(exception, "Error Occurred while downloading the file", onError);
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel("Download cancelled");
  }

  /// 2. Formats total size (Bytes -> GB, MB, KB)
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes >= 1024 * 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB";
    } else if (bytes >= 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    } else if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else if (bytes >= 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "$bytes B";
    }
  }

  /// Formats raw seconds into a clean digital clock string (e.g., "02:30" or "1:15:00")
  String _formatTimeLeft(double totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = ((totalSeconds % 3600) ~/ 60);
    int seconds = (totalSeconds % 60).toInt();

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      String hoursStr = hours.toString().padLeft(2, '0');
      return "$hoursStr:$minutesStr:$secondsStr";
    } else {
      return "$minutesStr:$secondsStr";
    }
  }

  /// Formats raw bytes per second into a readable string
  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond >= 1024 * 1024) {
      return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s";
    } else if (bytesPerSecond >= 1024) {
      return "${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s";
    } else {
      return "${bytesPerSecond.toStringAsFixed(0)} B/s";
    }
  }

  /// Helper to route the error to the callback OR throw the exception
  String? _handleErrorBridge(
    FileDownloadException exception,
    String legacyString,
    void Function(String)? onErrorCallback,
  ) {
    if (onErrorCallback != null) {
      // User provided the callback: send legacy error, don't throw exception.
      onErrorCallback(legacyString);
      return null;
    } else {
      // User did not provide the callback: throw the exception.
      throw exception;
    }
  }

  /// Maps Dio's internal error types to your custom Enum
  DownloadErrorType _mapDioErrorToEnum(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DownloadErrorType.networkTimeout;
      case DioExceptionType.badResponse:
        return DownloadErrorType.badResponse;
      case DioExceptionType.connectionError:
        return DownloadErrorType.noInternetConnection;
      case DioExceptionType.cancel:
        return DownloadErrorType.cancelled;
      default:
        return DownloadErrorType.unknown;
    }
  }

  /// Keeps the exact same strings you had before so you don't break existing apps
  String _getLegacyErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Request Timeout\nTry again later";
      case DioExceptionType.badResponse:
        return "Bad Response : ${e.error.toString()}";
      case DioExceptionType.cancel:
        return "Download cancelled";
      case DioExceptionType.unknown:
        return "Error : ${e.error.toString()}";
      case DioExceptionType.connectionError:
        return "Check your Internet connection and try again";
      default:
        return "Something went wrong";
    }
  }
}
