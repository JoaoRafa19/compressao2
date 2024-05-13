import 'package:compressao2/src/core/local_storage_constants.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestClient extends DioForNative {
  RestClient(String baseUrl)
      : super(
          BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
              headers: {
                'Accept': 'application/json',
                'Accept-Language': 'pt-BR',
              }),
        ) {
    interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
      AuthInterceptor(),
    ]);
  }
  RestClient get auth {
    options.extra['DIO_AUTH_KEY'] = true;
    return this;
  }

  RestClient get unAuth {
    options.extra['DIO_AUTH_KEY'] = false;
    return this;
  }
}

final class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final RequestOptions(:headers, :extra) = options;
    const authHeaderKey = 'Authorization';
    headers.remove(authHeaderKey);
    if (extra case {'DIO_AUTH_KEY': true}) {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString(LocalStorageConstants.accessToken);
      const envToken =
          bool.hasEnvironment("TOKEN") ? String.fromEnvironment("TOKEN") : null;
      if (envToken != null) {
        headers.addAll({authHeaderKey: 'Bearer ${token ?? envToken}'});
      }
    }
    headers.remove("DIO_AUTH_KEY");
    handler.next(options);
  }
}
