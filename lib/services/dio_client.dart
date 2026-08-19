import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

const _storage = FlutterSecureStorage();

void Function()? onSessionExpired;

final _plainDio = Dio(BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));

Future<String>? _refreshFuture;

Future<String> _performRefresh() async {
  final refreshToken = await _storage.read(key: 'refresh_token');
  if (refreshToken == null) {
    throw Exception('Tidak ada refresh token tersimpan');
  }
  final response = await _plainDio.post('/api/auth/refresh', data: {
    'refreshToken': refreshToken,
  });
  final newAccessToken = response.data['token'] as String;
  await _storage.write(key: 'jwt_token', value: newAccessToken);
  return newAccessToken;
}

final Dio dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),)
)
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthFailure = error.response?.statusCode == 401 || error.response?.statusCode == 403;
        final isAuthEndpoint = error.requestOptions.path.startsWith('/api/auth/');

        if (!isAuthFailure || isAuthEndpoint) {
          return handler.next(error);
        }

        try {
          // kalau sudah ada refresh yang lagi berjalan (dipicu request lain
          // yang gagal bersamaan), tunggu YANG SAMA — bukan mulai baru
          _refreshFuture ??= _performRefresh();
          final newAccessToken = await _refreshFuture!;
          _refreshFuture = null;

          error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(error.requestOptions);
          handler.resolve(retryResponse);
        } catch (_) {
          _refreshFuture = null;
          await _storage.delete(key: 'jwt_token');
          await _storage.delete(key: 'refresh_token');
          onSessionExpired?.call();
          handler.next(error);
        }
      },
    ),
  );