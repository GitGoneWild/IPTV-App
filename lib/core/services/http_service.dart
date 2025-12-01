import 'dart:convert';

import 'package:dio/dio.dart';

/// HTTP client service for API calls
class HttpService {
  HttpService({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  final Dio _dio;

  static BaseOptions get _defaultOptions => BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      );

  /// GET request
  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ResponseType? responseType,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<dynamic>> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file as string
  Future<String> downloadString(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      return response.data.toString();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file as bytes
  Future<List<int>> downloadBytes(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download and parse JSON
  Future<dynamic> downloadJson(String url) async {
    try {
      final response = await _dio.get(url);
      if (response.data is String) {
        return json.decode(response.data as String);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle DioException and convert to a more usable format
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpTimeoutException(
          'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return HttpConnectionException(
          'Unable to connect. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.statusMessage ?? 'Unknown error';
        return HttpResponseException(
          statusCode: statusCode,
          message: 'Server error: $statusCode - $message',
        );
      case DioExceptionType.cancel:
        return HttpCancelledException('Request was cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return HttpUnknownException(
          error.message ?? 'An unknown error occurred.',
        );
    }
  }
}

/// Base HTTP exception
abstract class HttpException implements Exception {
  const HttpException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Timeout exception
class HttpTimeoutException extends HttpException {
  const HttpTimeoutException(super.message);
}

/// Connection exception
class HttpConnectionException extends HttpException {
  const HttpConnectionException(super.message);
}

/// Response exception with status code
class HttpResponseException extends HttpException {
  const HttpResponseException({
    required this.statusCode,
    required String message,
  }) : super(message);

  final int statusCode;
}

/// Request cancelled exception
class HttpCancelledException extends HttpException {
  const HttpCancelledException(super.message);
}

/// Unknown exception
class HttpUnknownException extends HttpException {
  const HttpUnknownException(super.message);
}
