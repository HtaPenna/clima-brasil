import 'package:dio/dio.dart';

/// Interface básica de serviço HTTP
abstract class HttpService {
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters});
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters});
}

/// Implementação do serviço HTTP usando a biblioteca Dio
class DioHttpService implements HttpService {
  final Dio _dio;

  DioHttpService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Podemos adicionar interceptores para logs ou tratamento de erro futuramente
  }

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception('Erro na requisição GET: ${e.message}');
    }
  }

  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(url, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception('Erro na requisição POST: ${e.message}');
    }
  }
}
