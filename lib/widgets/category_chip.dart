import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D1B2A);
    const Color goldColor = Color(0xFFE9C46A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? goldColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? goldColor : Colors.white10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ),
    );
  }
}
