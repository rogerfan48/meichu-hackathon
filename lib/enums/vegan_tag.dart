import 'package:flutter/material.dart';

enum VeganTags {
  vegan, // 全素
  veganPartial,
  lacto, // 蛋奶素
  lactoPartial,
  vegetarian, // 五辛素
  vegetarianPartial,
  nonVegetarian, // 葷食
}

class VeganTag {
  const VeganTag(this.title, this.image, this.level);

  final String title;
  final Image image;
  final int level;

  factory VeganTag.fromString(String tag) {
    switch (tag) {
      case "vegan":
        return veganTags[VeganTags.vegan]!;
      case "veganPartial":
        return veganTags[VeganTags.veganPartial]!;
      case "lactoOvo":
        return veganTags[VeganTags.lacto]!;
      case "lactoOvoPartial":
        return veganTags[VeganTags.lactoPartial]!;
      case "vegetarian":
        return veganTags[VeganTags.vegetarian]!;
      case "vegetarianPartial":
        return veganTags[VeganTags.vegetarianPartial]!;
      case "nonVegetarian":
        return veganTags[VeganTags.nonVegetarian]!;
      default:
        throw ArgumentError("Unknown vegan tag: $tag");
    }
  }

  VeganTags toVeganTags() {
    switch (title) {
      case "Vegan":
        return VeganTags.vegan;
      case "Vegan (Partial)":
        return VeganTags.veganPartial;
      case "Lacto":
        return VeganTags.lacto;
      case "Lacto (Partial)":
        return VeganTags.lactoPartial;
      case "Vegetarian":
        return VeganTags.vegetarian;
      case "Vegetarian (Partial)":
        return VeganTags.vegetarianPartial;
      case "Non Vegetarian":
        return VeganTags.nonVegetarian;
      default:
        throw ArgumentError("Unknown vegan tag: $title");
    }
  }
}

final veganTags = {
  VeganTags.vegan: VeganTag("Vegan", Image.asset('assets/imgs/leaf.png', width: 150), 0),
  VeganTags.veganPartial: VeganTag("Vegan (Partial)", Image.asset('assets/imgs/leaf.png', width: 150), 1),
  VeganTags.lacto: VeganTag("Lacto", Image.asset('assets/imgs/milk.png', width: 150), 2),  
  VeganTags.lactoPartial: VeganTag("Lacto (Partial)", Image.asset('assets/imgs/milk.png', width: 150), 3),
  VeganTags.vegetarian: VeganTag("Vegetarian", Image.asset('assets/imgs/onion.png', width: 150), 4),
  VeganTags.vegetarianPartial: VeganTag("Vegetarian (Partial)", Image.asset('assets/imgs/onion.png', width: 150), 5),
  VeganTags.nonVegetarian: VeganTag("Non Vegetarian", Image.asset('assets/imgs/meat.png', width: 150), 6),
};

extension VeganTagsExtension on VeganTags {
  int get level {
    return veganTags[this]!.level;
  }
}
