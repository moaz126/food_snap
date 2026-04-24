import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class FoodAnalysisEvent extends Equatable {
  const FoodAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeFoodEvent extends FoodAnalysisEvent {
  final File imageFile;

  const AnalyzeFoodEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile.path];
}

class ResetFoodAnalysisEvent extends FoodAnalysisEvent {
  const ResetFoodAnalysisEvent();
}
