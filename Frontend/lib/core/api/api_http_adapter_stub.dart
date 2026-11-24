import 'package:dio/dio.dart';

void configureSecureHttpAdapter(Dio dio, {required String expectedSha256Pin}) {
  // No-op para Flutter Web (o navegador gerencia TLS e certificados)
}
