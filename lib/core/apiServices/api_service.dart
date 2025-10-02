import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() : _dio = Dio();

  Future<void> downloadFile({
    required String downloadFileUrl,
    void Function(double progress)? onProgress,
    void Function(String filePath)? onSuccess,
    void Function(String error)? onError,
    String? downloadFileName,
  }) async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) return;

      String savePath =
          "${directory.path}/${downloadFileName ?? "downloadApk"}.apk";
      Response response = await _dio.download(
        downloadFileUrl,
        savePath,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            double progress = count / total;
            if (onProgress != null) {
              onProgress(progress);
            }
          }
        },
      );
      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess(savePath);
        }
      } else {
        if (onError != null) {
          onError("Unable to download the file");
        }
      }
    } on DioException catch (e, sc) {
      log(e.toString(), stackTrace: sc);
      String error = _handleDioException(e);
      if (onError != null) {
        onError(error);
      }
    } catch (e, sc) {
      log(e.toString(), stackTrace: sc);
      if (onError != null) {
        onError("Error Occurred while downloading the file");
      }
    }
  }

  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Request Timeout\nTry again later";
      case DioExceptionType.badResponse:
        return "Bad Response : ${e.error.toString()}";
      case DioExceptionType.unknown:
        return "Error : ${e.error.toString()}";
      case DioExceptionType.connectionError:
        return "Check your Internet connection and try again";
      default:
        return "Something went wrong";
    }
  }
}
