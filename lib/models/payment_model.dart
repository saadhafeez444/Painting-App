import 'package:flutter/material.dart';

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;
  final Map<String, String> fields;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
    required this.fields,
  });
}