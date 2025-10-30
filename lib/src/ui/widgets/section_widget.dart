// ui/widgets/section_widget.dart
import 'package:flutter/material.dart';
import '../../models/section.dart';

class SectionWidget extends StatelessWidget {
  final Section section;
  const SectionWidget({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.heading,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(section.text),
            if (section.imageUrl != null) ...[
              const SizedBox(height: 8),
              Image.network(
                section.imageUrl!,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
