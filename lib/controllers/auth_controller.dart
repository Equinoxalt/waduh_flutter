import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool isCheckingSession = true;
  bool isLoggedIn = false;
  String? errorMessage;

  AuthController() {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final token = await _storage.read(key: 'jwt_token');
    isLoggedIn = token != null;
    isCheckingSession = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);
      await _storage.write(key: 'jwt_token', value: token);
      isLoggedIn = true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = 'Server tidak merespons. Cek koneksi & alamat server';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Email atau password salah';
      } else {
        errorMessage = 'Gagal terhubung ke server';
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    isLoggedIn = false;
    notifyListeners();
  }
}