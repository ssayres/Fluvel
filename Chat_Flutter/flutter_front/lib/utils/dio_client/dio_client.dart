import 'package:dio/dio.dart';

class DioClient {
  static DioClient? _singleton;

  static  DioClient? _dio;

  DioClient._(){
    _dio = createDioClient();
  };
  

  factory DioClient() {
    return _singleton ??= DioClient._();
  }

  Dio createDioClient() {

  }
}
