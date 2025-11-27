import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Authentication provider for state management
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Register new user
  Future<bool> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    int? age,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        age: age,
        gender: gender,
      );

      if (response.success) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      // Continue logout even if API fails
      _user = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore session from saved token (called on app startup)
  Future<bool> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Restore token from storage
      final response = await _authService.restoreSession();

      if (response.success && response.user != null) {
        // 2. Token exists, now fetch real user profile to get correct ID
        try {
          final userBasic = await _userService.getBasicProfile();

          if (userBasic.id != null) {
            // Update user with real data from API
            _user = User(
              id: userBasic.id!,
              userName: userBasic.userName ?? 'User',
              email: 'user@app.com', // Placeholder as BasicProfile doesn't return email
              gioiTinh: userBasic.gender,
              profilePicture: userBasic.profilePicture,
              avatarUrl: userBasic.profilePicture,
              displayName: userBasic.userName,
            );
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
             throw Exception('User ID is null');
          }
        } catch (e) {
          print('[AuthProvider] Failed to fetch user profile with restored token: $e');
          // Token might be invalid or expired
          await logout();
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _user = null;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _user = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}