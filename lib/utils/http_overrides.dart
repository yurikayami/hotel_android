import 'dart:io';

/// Custom HTTP override to bypass SSL certificate validation
/// ⚠️ WARNING: Only use this in DEVELOPMENT mode!
/// In production, you should use proper SSL certificates.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow all certificates in development
        return true;
      };
  }
}

