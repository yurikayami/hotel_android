// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionHistory _$PredictionHistoryFromJson(Map<String, dynamic> json) =>
    PredictionHistory(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      imagePath: json['imagePath'] as String,
      foodName: json['foodName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      mealType: json['mealType'] as String?,
      advice: json['advice'] as String?,
      suitable: (json['suitable'] as num?)?.toInt(),
      suggestions: json['suggestions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => PredictionDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PredictionHistoryToJson(PredictionHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'imagePath': instance.imagePath,
      'foodName': instance.foodName,
      'confidence': instance.confidence,
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carbs': instance.carbs,
      'mealType': instance.mealType,
      'advice': instance.advice,
      'suitable': instance.suitable,
      'suggestions': instance.suggestions,
      'createdAt': instance.createdAt.toIso8601String(),
      'details': instance.details?.map((e) => e.toJson()).toList(),
    };

PredictionDetail _$PredictionDetailFromJson(Map<String, dynamic> json) =>
    PredictionDetail(
      id: (json['id'] as num?)?.toInt(),
      predictionHistoryId: (json['predictionHistoryId'] as num?)?.toInt(),
      label: json['label'] as String,
      weight: (json['weight'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );

Map<String, dynamic> _$PredictionDetailToJson(PredictionDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'predictionHistoryId': instance.predictionHistoryId,
      'label': instance.label,
      'weight': instance.weight,
      'confidence': instance.confidence,
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carbs': instance.carbs,
    };
