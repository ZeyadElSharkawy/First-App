import 'package:flutter/material.dart';

class StyledLabel extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  const StyledLabel({
    super.key,
    required this.text,
    this.size = 16,
    this.color = Colors.black87,
    this.weight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: size, color: color, fontWeight: weight),
    );
  }
}
