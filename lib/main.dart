import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'utils/http_overrides.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/food_analysis_provider.dart';
import 'providers/bai_thuoc_provider.dart';
import 'providers/mon_an_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'services/food_analysis_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'screens/debug_screen.dart';

void main() {
  // ⚠️ Only for development - bypass SSL certificate validation
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BaiThuocProvider()),
        ChangeNotifierProvider(create: (_) => MonAnProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        // Provide FoodAnalysisService
        Provider<FoodAnalysisService>(
          create: (_) => FoodAnalysisService(
            dio: Dio()
              ..options.connectTimeout = const Duration(seconds: 30)
              ..options.receiveTimeout = const Duration(seconds: 30),
          ),
        ),
        // Provide FoodAnalysisProvider
        ChangeNotifierProxyProvider<FoodAnalysisService, FoodAnalysisProvider>(
          create: (context) => FoodAnalysisProvider(
            context.read<FoodAnalysisService>(),
          ),
          update: (context, service, previous) =>
              previous ?? FoodAnalysisProvider(service),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Apply status bar visibility based on setting
          if (themeProvider.hideStatusBar) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
          } else {
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
          }

          return MaterialApp(
            title: 'Hotel App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            supportedLocales: const [
              Locale('vi', 'VN'), // Vietnamese
              Locale('en', 'US'), // English
            ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32), // Green for health & food
            brightness: Brightness.light,
            primary: const Color(0xFF2E7D32), // Deep green
            secondary: const Color(0xFFFF6F00), // Vibrant orange
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2E7D32),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.dark,
            primary: const Color(0xFF4CAF50), // Lighter green for dark mode
            secondary: const Color(0xFFFF9800), // Lighter orange
            surface: themeProvider.pureDarkMode ? Colors.black : const Color(0xFF10140F),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: themeProvider.pureDarkMode ? Colors.black : const Color(0xFF10140F),
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: themeProvider.pureDarkMode ? Colors.black : const Color(0xFF10140F),
            foregroundColor: const Color(0xFF4CAF50),
          ),
          cardTheme: CardThemeData(
            color: themeProvider.pureDarkMode ? const Color(0xFF10140F) : const Color(0xFF1E1E1E),
            elevation: 2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/debug': (context) => const DebugScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/profile/') ?? false) {
            final userId = settings.name!.replaceFirst('/profile/', '');
            return MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: userId),
              settings: settings,
            );
          }
          return null;
        },
          );
        },
      ),
    );
  }
}

