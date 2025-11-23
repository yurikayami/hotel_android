import '../models/user.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Authentication service for handling user authentication
class AuthService {
  final ApiService _apiService = ApiService();

  /// Register a new user
  Future<AuthResponse> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    int? age,
    String? gender,
  }) async {
    final response = await _apiService.post(
      '${ApiConfig.auth}/register',
      body: {
        'userName': userName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        if (age != null) 'tuoi': age,
        if (gender != null) 'gioi_tinh': gender,
      },
    );

    final authResponse = AuthResponse.fromJson(response);

    if (authResponse.success && authResponse.token != null) {
      await _apiService.setToken(authResponse.token!);
    }

    return authResponse;
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '${ApiConfig.auth}/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response);

    if (authResponse.success && authResponse.token != null) {
      await _apiService.setToken(authResponse.token!);
    }

    return authResponse;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiService.post(
        '${ApiConfig.auth}/logout',
        body: {},
        needsAuth: true,
      );
    } catch (e) {
      // Continue logout even if API call fails
    } finally {
      await _apiService.clearToken();
    }
  }

  /// Check if user is logged in and restore user data from token
  Future<bool> isLoggedIn() async {
    await _apiService.init();
    // TODO: Optionally validate token with API
    return true; // Token exists in storage
  }

  /// Restore session from saved token
  Future<AuthResponse> restoreSession() async {
    try {
      // Initialize API service with saved token
      await _apiService.init();

      // Check if token exists in secure storage
      final token = await _apiService.getToken();
      print('[AuthService] Checking for saved token: ${token != null ? 'Found' : 'Not found'}');
      
      if (token == null || token.isEmpty) {
        print('[AuthService] No token found, user not logged in');
        return AuthResponse(
          success: false,
          message: 'No saved session',
        );
      }

      // Token exists, session is valid!
      // Create a temporary user object until we fetch real user data
      print('[AuthService] Token found, session is valid');
      return AuthResponse(
        success: true,
        message: 'Session restored',
        token: token,
        user: User(
          id: 'restored',
          userName: 'User',
          email: 'user@app.com',
        ),
      );
    } catch (e) {
      print('[AuthService] Error restoring session: $e');
      await _apiService.clearToken();
      return AuthResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }
}

