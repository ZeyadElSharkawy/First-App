import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const StyledButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).primaryColor;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: c,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: padding,
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
