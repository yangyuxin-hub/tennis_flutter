import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';

/// API 服务类 - 封装 Dio 网络请求
class ApiService {
  late Dio _dio;
  String? _token;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.timeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 请求拦截器 - 添加 token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          _logger.d('请求: ${options.method} ${options.path}');
          _logger.d('请求头: ${options.headers}');
          if (options.data != null) {
            _logger.d('请求数据: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger
              .d('响应: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('响应数据: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('错误: ${error.message}');
          if (error.response != null) {
            _logger.e('错误响应: ${error.response?.data}');
          }

          // 处理 401 未授权错误
          if (error.response?.statusCode == 401) {
            _logger.w('Token 已过期或无效，需要重新登录');
            // 这里可以触发登出逻辑
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// 设置 token
  void setToken(String? token) {
    _token = token;
    _logger.i('Token 已更新');
  }

  /// 清除 token
  void clearToken() {
    _token = null;
    _logger.i('Token 已清除');
  }

  /// GET 请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 请求
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理错误
  Exception _handleError(DioException error) {
    String message = '网络请求失败';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '连接超时，请检查网络';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = data?['detail'] ?? '请求参数错误';
              break;
            case 401:
              message = '未授权，请重新登录';
              break;
            case 403:
              message = '没有权限访问';
              break;
            case 404:
              message = '请求的资源不存在';
              break;
            case 500:
              message = '服务器错误';
              break;
            default:
              message = data?['detail'] ?? '请求失败 ($statusCode)';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          message = '网络连接失败，请检查网络';
        } else {
          message = '未知错误: ${error.message}';
        }
        break;
      default:
        message = '网络错误: ${error.message}';
    }

    _logger.e('API 错误: $message');
    return Exception(message);
  }
}

/// 全局单例
final apiService = ApiService();
