import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String status;
  final IconData icon;
  final Color iconBgColor;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.status,
    required this.icon,
    required this.iconBgColor,
  });
}
