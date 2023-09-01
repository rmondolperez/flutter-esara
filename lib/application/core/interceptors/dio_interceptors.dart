import 'package:dio/dio.dart';

class DioInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = Headers.formUrlEncodedContentType;
    options.responseType = ResponseType.plain;
    super.onRequest(options, handler);
  }
}
