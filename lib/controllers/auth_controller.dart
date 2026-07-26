import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);
      await _storage.write(key: 'jwt_token', value: token);
      isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      isLoading = false;
      errorMessage = e.response?.statusCode == 401
          ? 'Email atau password salah'
          : 'Gagal terhubung ke server';
      notifyListeners();
      return false;
    }
  }
}