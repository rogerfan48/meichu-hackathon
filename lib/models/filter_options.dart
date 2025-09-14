import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/enums/halal_tag.dart';

class FilterOptions {
  Set<GenreTags> selectedGenres;
  Set<VeganTags> selectedVeganTags;
  HalalTags? halalStatus;

  bool isOpenNow;
  RangeValues priceRange;
  double minRating;

  FilterOptions({
    required this.selectedGenres,
    required this.selectedVeganTags,
    this.halalStatus,
    this.isOpenNow = false,
    this.priceRange = const RangeValues(1, 4),
    this.minRating = 0.0,
  });

  int get maxVeganLevel {
    if (selectedVeganTags.isEmpty) {
      return veganTags[VeganTags.nonVegetarian]!.level;
    }
    return selectedVeganTags.map((tag) => tag.level).reduce((a, b) => a > b ? a : b);
  }

  FilterOptions copyWith({
    Set<GenreTags>? selectedGenres,
    Set<VeganTags>? selectedVeganTags,
    HalalTags? halalStatus,
    bool? isOpenNow,
    RangeValues? priceRange,
    double? minRating,
  }) {
    return FilterOptions(
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedVeganTags: selectedVeganTags ?? this.selectedVeganTags,
      halalStatus: halalStatus ?? this.halalStatus,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
    );
  }
}
