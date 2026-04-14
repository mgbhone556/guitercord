import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.isDark,
    this.title = "Your stage is empty!",
    this.subtitle = "Songs you heart will appear here.",
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey("empty_state_widget"),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 24),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
