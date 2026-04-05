import 'package:flutter/material.dart';

class CustomListInput extends StatefulWidget {
  final String label;
  final List<String> initialItems;
  final String hintText;
  final IconData icon;
  final Color? chipColor;
  final Function(List<String>) onChanged;

  const CustomListInput({
    super.key,
    required this.label,
    required this.initialItems,
    required this.onChanged,
    this.hintText = "Add item...",
    this.icon = Icons.add_circle_outline,
    this.chipColor,
  });

  @override
  State<CustomListInput> createState() => _CustomListInputState();
}

class _CustomListInputState extends State<CustomListInput> {
  late List<String> items;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use a copy of the list to avoid modifying the original list directly
    items = List.from(widget.initialItems);
  }

  // Handle case where initialItems might change from parent (e.g. during an Edit)
  @override
  void didUpdateWidget(CustomListInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      items = List.from(widget.initialItems);
    }
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !items.contains(text)) {
      setState(() {
        items.add(text);
        _controller.clear();
        widget.onChanged(items);
      });
    }
  }

  void _removeItem(String item) {
    setState(() {
      items.remove(item);
      widget.onChanged(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // The Chips Area
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: -4, // Tighter vertical spacing
              children: items.map((item) {
                return Chip(
                  label: Text(item, style: const TextStyle(fontSize: 13)),
                  backgroundColor:
                      widget.chipColor ?? theme.primaryColor.withOpacity(0.1),
                  deleteIcon: const Icon(Icons.cancel, size: 18),
                  onDeleted: () => _removeItem(item),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Input Field
        TextField(
          controller: _controller,
          onSubmitted: (_) => _addItem(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 14),
            suffixIcon: IconButton(
              onPressed: _addItem,
              icon: Icon(widget.icon, color: theme.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
