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
          color: isSelected ? color : (theme.cardTheme.color ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: Colors.transparent) : Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (isSelected)
               BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isLarge ? 20 : 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: isLarge ? 32 : 24, 
                color: isSelected ? Colors.white : color
              ),
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              title, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (theme.textTheme.bodyMedium?.color ?? Colors.black87),
                fontSize: isLarge ? 16 : 13,
              )
            ),
          ],
        ),
      ),
    );
  }
}
