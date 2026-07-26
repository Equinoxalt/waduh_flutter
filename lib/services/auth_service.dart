import 'dio_client.dart';

class AuthService {
  Future<String> login(String email, String password) async {
    final response = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    return response.data['token'] as String;
  }
}