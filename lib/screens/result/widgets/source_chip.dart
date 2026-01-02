import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SourceChip extends StatelessWidget {
  final String label;
  final bool isMatch;

  const SourceChip({super.key, required this.label, required this.isMatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMatch ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isMatch ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMatch ? LucideIcons.checkCircle : LucideIcons.globe,
            size: 16,
            color: isMatch ? Colors.green[700] : Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isMatch ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
