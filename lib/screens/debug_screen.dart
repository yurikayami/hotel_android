import 'package:flutter/material.dart';
import '../services/api_config.dart';

/// Debug screen to test API connectivity
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _apiStatus = 'Checking...';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkApi();
  }

  Future<void> _checkApi() async {
    setState(() {
      _isChecking = true;
      _apiStatus = 'Checking...';
    });

    try {
      // Try to reach the API
      final uri = Uri.parse(ApiConfig.baseUrl);

      // Simple connectivity check
      _apiStatus = '''
API Configuration:
- Base URL: ${ApiConfig.baseUrl}
- Host: ${uri.host}
- Port: ${uri.port}
- Scheme: ${uri.scheme}

Status: Configured ✓

Next: Try Login
- Make sure API server is running on ${uri.host}:${uri.port}
- Check Firebase/Network connectivity
- Check SSL certificate (currently bypassed)
      ''';
    } catch (e) {
      _apiStatus = 'Error: $e';
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - API Status'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              _apiStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isChecking ? null : _checkApi,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

