import 'package:flutter/material.dart';

class StyledDropdown extends StatefulWidget {
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final String hint;

  const StyledDropdown({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.hint = '',
  });

  @override
  State<StyledDropdown> createState() => _StyledDropdownState();
}

class _StyledDropdownState extends State<StyledDropdown> {
  String? value;

  @override
  void initState() {
    super.initState();
    value =
        widget.initialValue ??
        (widget.items.isNotEmpty ? widget.items.first : null);
  }

  @override
  void didUpdateWidget(StyledDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update value if initialValue or items changed
    if (oldWidget.initialValue != widget.initialValue ||
        oldWidget.items != widget.items) {
      if (widget.items.contains(widget.initialValue)) {
        value = widget.initialValue;
      } else if (widget.items.isNotEmpty) {
        value = widget.items.first;
      } else {
        value = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: widget.hint.isNotEmpty ? Text(widget.hint) : null,
          items: widget.items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() => value = v);
            if (widget.onChanged != null) widget.onChanged!(v);
          },
        ),
      ),
    );
  }
}
