import 'package:json_annotation/json_annotation.dart';

part 'prediction_history.g.dart';

/// Prediction history model for food analysis
@JsonSerializable(explicitToJson: true)
class PredictionHistory {
  final int id;
  final String userId;
  final String imagePath;
  final String foodName;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String? mealType;
  final String? advice;
  final int? suitable;
  final String? suggestions;
  final DateTime createdAt;
  final List<PredictionDetail>? details;

  PredictionHistory({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.foodName,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.mealType,
    this.advice,
    this.suitable,
    this.suggestions,
    required this.createdAt,
    this.details,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> json) {
    try {
      return PredictionHistory(
        id: json['id'] as int,
        userId: json['userId'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        foodName: json['foodName'] as String? ?? 'Unknown Food',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
        mealType: json['mealType'] as String?,
        advice: json['advice'] as String?,
        suitable: json['suitable'] as int?,
        suggestions: json['suggestions'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        details: (json['details'] as List<dynamic>?)
            ?.map((e) => PredictionDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Error parsing PredictionHistory: $e');
    }
  }

  Map<String, dynamic> toJson() => _$PredictionHistoryToJson(this);
}

/// Prediction detail model for individual food items in analysis
@JsonSerializable(explicitToJson: true)
class PredictionDetail {
  final int? id;
  final int? predictionHistoryId;
  final String label;
  final double weight;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  PredictionDetail({
    this.id,
    this.predictionHistoryId,
    required this.label,
    required this.weight,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory PredictionDetail.fromJson(Map<String, dynamic> json) {
    try {
      return PredictionDetail(
        id: json['id'] as int?,
        predictionHistoryId: json['predictionHistoryId'] as int?,
        label: json['label'] as String? ?? 'Unknown',
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw FormatException('Error parsing PredictionDetail: $e');
    }
  }

  Map<String, dynamic> toJson() => _$PredictionDetailToJson(this);
}

