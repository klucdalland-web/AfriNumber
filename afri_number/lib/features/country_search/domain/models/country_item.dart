import 'package:flutter/material.dart';

class CountryItem {
  final String id;
  final String name;
  final String code;
  final int availableNumbers;
  final bool isPopular;
  final IconData icon;

  const CountryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.availableNumbers,
    this.isPopular = false,
    this.icon = Icons.public_rounded,
  });
}
