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
    void Function(String error)? onError,
    String? downloadFileName,
  }) async {
    _cancelToken = CancelToken();
    try {
      Directory? directory = await getExternalStorageDirectory();

      // 1. Handle Storage Denial
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
          if (total > 0 && onProgress != null) {
            onProgress(count / total);
          }
        },
      );

      // 2. Handle Success vs Bad Status Code
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

      // 3. Map DioException to your Enum
      final exception = FileDownloadException(
        type: _mapDioErrorToEnum(e.type),
        statusCode: e.response?.statusCode,
        originalError: e,
      );

      // Get the legacy string for old users, but throw the exception for new users
      String legacyErrorString = _getLegacyErrorMessage(e);
      return _handleErrorBridge(exception, legacyErrorString, onError);
    } catch (e, sc) {
      log("Unknown Exception in downloadFile", error: e, stackTrace: sc);

      // 4. Handle completely unknown crashes
      final exception = FileDownloadException(type: DownloadErrorType.unknown, originalError: e);
      return _handleErrorBridge(exception, "Error Occurred while downloading the file", onError);
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel("Download cancelled");
  }

  /// Helper to route the error to the callback OR throw the exception
  Null _handleErrorBridge(
    FileDownloadException exception,
    String legacyString,
    void Function(String)? onErrorCallback,
  ) {
    if (onErrorCallback != null) {
      onErrorCallback(legacyString);
      return null;
    } else {
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
