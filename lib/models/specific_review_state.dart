import 'package:flutter/material.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:image_picker/image_picker.dart';

class SpecificReviewState {
  DishModel? selectedDish;
  int rating;
  final TextEditingController contentController;
  List<XFile> images;

  SpecificReviewState({
    this.selectedDish,
    this.rating = 0,
    List<XFile>? images,
  }) : contentController = TextEditingController(),
       images = images ?? [];
}
