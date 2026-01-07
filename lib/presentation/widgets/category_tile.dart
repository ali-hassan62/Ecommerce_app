import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isLarge;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.isLarge = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : (theme.cardTheme.color ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: color, width: 2) : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isLarge ? 20 : 12),
              decoration: BoxDecoration(
                color: isSelected ? color : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: isLarge ? 32 : 24, 
                color: isSelected ? theme.colorScheme.surface : color
              ),
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              title, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : (theme.textTheme.bodyMedium?.color ?? Colors.black87),
                fontSize: isLarge ? 16 : 13,
              )
            ),
          ],
        ),
      ),
    );
  }
}
