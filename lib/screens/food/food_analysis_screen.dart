import 'package:flutter/material.dart';
import 'food_camera_screen.dart';

/// Food Analysis Screen - Redirects to new Camera Screen
///
/// This screen has been split into three separate screens:
/// - FoodCameraScreen: Main camera interface for capturing/selecting images
/// - FoodResultScreen: Display analysis results
/// - FoodHistoryScreen: View past analyses
class FoodAnalysisScreen extends StatelessWidget {
  const FoodAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new camera screen
    return const FoodCameraScreen();
  }
}
