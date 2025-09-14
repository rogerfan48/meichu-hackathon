import 'dart:async';

import 'package:flutter/material.dart';

enum GenreTags { fastFood, chinese, western, indian, thai, korean, japanese, italian, taiwanese, vietnamese, hotpot, barbecue, teppanyaki, streetFood, drink, coffee, dessert }

class GenreTag {
  const GenreTag(this.title, this.color);

  final String title;
  final Color color;

  factory GenreTag.fromString(String tag) {
    switch (tag) {
      case "fastFood":
        return genreTags[GenreTags.fastFood]!;
      case "chinese":
        return genreTags[GenreTags.chinese]!;
      case "western":
        return genreTags[GenreTags.western]!;
      case "indian":
        return genreTags[GenreTags.indian]!;
      case "thai":
        return genreTags[GenreTags.thai]!;
      case "korean":
        return genreTags[GenreTags.korean]!;
      case "japanese":
        return genreTags[GenreTags.japanese]!;
      case "italian":
        return genreTags[GenreTags.italian]!;
      case "taiwanese":
        return genreTags[GenreTags.taiwanese]!;
      case "vietnamese":
        return genreTags[GenreTags.vietnamese]!;
      case "hotpot":
        return genreTags[GenreTags.hotpot]!;
      case "barbecue":
        return genreTags[GenreTags.barbecue]!;
      case "teppanyaki":
        return genreTags[GenreTags.teppanyaki]!;
      case "streetFood":
        return genreTags[GenreTags.streetFood]!;
      case "drink":
        return genreTags[GenreTags.drink]!;
      case "coffee":
        return genreTags[GenreTags.coffee]!;
      case "dessert":
        return genreTags[GenreTags.dessert]!;
      default:
        throw ArgumentError("Unknown genre tag: $tag");
    }
  }

  GenreTags toGenreTags() {
    switch (title) {
      case "Fast Food":
        return GenreTags.fastFood;
      case "Chinese":
        return GenreTags.chinese;
      case "Western":
        return GenreTags.western;
      case "Indian":
        return GenreTags.indian;
      case "Thai":
        return GenreTags.thai;
      case "Korean":
        return GenreTags.korean;
      case "Japanese":
        return GenreTags.japanese;
      case "Italian":
        return GenreTags.italian;
      case "Taiwanese":
        return GenreTags.taiwanese;
      case "Vietnamese":
        return GenreTags.vietnamese;
      case "Hotpot":
        return GenreTags.hotpot;
      case "Barbecue":
        return GenreTags.barbecue;
      case "Teppanyaki":
        return GenreTags.teppanyaki;
      case "Street Food":
        return GenreTags.streetFood;
      case "Drink":
        return GenreTags.drink;
      case "Coffee":
        return GenreTags.coffee;
      case "Dessert":
        return GenreTags.dessert;
      default:
        throw ArgumentError("Unknown genre tag: $title");
    }
  }
}

const genreTags = {
  GenreTags.fastFood: GenreTag("Fast Food", Color(0xFFFCADAD)),
  GenreTags.chinese: GenreTag("Chinese", Color(0xFFE45454)),
  GenreTags.western: GenreTag("Western", Color(0xFF0088FF)),
  GenreTags.indian: GenreTag("Indian", Color(0xFFDC9832)),
  GenreTags.thai: GenreTag("Thai", Color(0xFFCFBA30)),            
  GenreTags.korean: GenreTag("Korean", Color(0xFFEBDCE8)),
  GenreTags.japanese: GenreTag("Japanese", Color(0xFFB2D6FF)),
  GenreTags.italian: GenreTag("Italian", Color(0xFFB2FFB2)),
  GenreTags.taiwanese: GenreTag("Taiwanese", Color(0xFFB2B2FF)),
  GenreTags.vietnamese: GenreTag("Vietnamese", Color(0xFFEBEF1B)),
  GenreTags.hotpot: GenreTag("Hotpot", Color(0xFFDCDCDC)),
  GenreTags.barbecue: GenreTag("Barbecue", Color(0xFFFFA426)),
  GenreTags.teppanyaki: GenreTag("Teppanyaki", Color(0xFF41CF41)),
  GenreTags.streetFood: GenreTag("Street Food", Color(0xFFD157DA)),
  GenreTags.drink: GenreTag("Drink", Color(0xFF5AE5B5)),
  GenreTags.coffee: GenreTag("Coffee", Color(0xFF38D4E6)),
  GenreTags.dessert: GenreTag("Dessert", Color.fromARGB(255, 255, 251, 182)),
};
