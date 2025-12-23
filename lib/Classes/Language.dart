import 'package:flutter/material.dart';

class LanguageSwitch extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<bool> onChanged;

  const LanguageSwitch({
    super.key,
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isArabic ? Alignment.topLeft : Alignment.topRight;
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: !isArabic ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'English',
                  style: TextStyle(
                    color: !isArabic ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isArabic ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'العربية',
                  style: TextStyle(
                    color: isArabic ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
