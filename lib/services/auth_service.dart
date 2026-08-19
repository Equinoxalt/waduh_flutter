import 'dio_client.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  AuthTokens({required this.accessToken, required this.refreshToken});
}

class AuthService {
  Future<AuthTokens> login(String email, String password) async {
    final response = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthTokens(
      accessToken: response.data['token'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
  }

  Future<AuthTokens> register(String email, String password) async {
    final response = await dio.post('/api/auth/register', data: {
      'email': email,
      'password': password,
    });
    return AuthTokens(
      accessToken: response.data['token'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
  }
}