/// API Configuration
class ApiConfig {
  // Base URL - Update this to match your API server
  // Backend running on: https://192.168.1.3:7135

  static const String ipComputer = '192.168.1.3';
  static const String baseUrl = 'https://$ipComputer:7135/api';

  // Endpoints
  static const String auth = '/Auth';
  static const String posts = '/Post';
  static const String foodAnalysis = '/FoodAnalysis';
  static const String monAn = '/MonAn';
  static const String baiThuoc = '/BaiThuocAPI'; 
  static const String nuocUong = '/NuocUong';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);  
  static const Duration receiveTimeout = Duration(seconds: 30);
}



