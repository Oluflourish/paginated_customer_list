import 'package:dio/dio.dart';

class HttpService {
  late final Dio _dio;

  HttpService() : _dio = Dio() {
    _dio.options.baseUrl = 'https://dummyjson.com/';
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return response;
    } on DioException catch (e) {
      throw Exception('Failed to load data: ${e.message}');
    }
  }
}
