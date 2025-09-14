import 'package:flutter/material.dart';

enum HalalTags { yes, no }

class HalalTag {
  const HalalTag(this.title, this.image);

  final String title;
  final Image image;
  
  factory HalalTag.fromString(String tag) {
    switch (tag) {
      case "yes":
        return halalTags[HalalTags.yes]!;
      case "no":
        return halalTags[HalalTags.no]!;
      default:
        throw ArgumentError("Unknown halal tag: $tag");
    }
  }
}

final halalTags = {
  HalalTags.yes: HalalTag("Yes", Image.asset('assets/imgs/halal.png', width: 150)),
  HalalTags.no: HalalTag("No", Image.asset('assets/imgs/halal.png', width: 150)),
};
