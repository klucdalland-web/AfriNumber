import 'package:flutter/material.dart';

class OfferItem {
  final String id;
  final String country;
  final String title;
  final String startingPrice;
  final IconData countryIcon;

  const OfferItem({
    required this.id,
    required this.country,
    required this.title,
    required this.startingPrice,
    required this.countryIcon,
  });
}
