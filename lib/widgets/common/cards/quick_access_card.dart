import 'package:flutter/material.dart';

class ModernQuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final VoidCallback onTap;
  final Color iconColor;
  
  const ModernQuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Küçük radius
        onTap: onTap,
        splashColor: iconColor.withAlpha(31), // 0.12 * 255 = 31
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Küçük radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20), // 0.08 * 255 = 20
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 10,
          ), // Daha az padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(18), // 0.07 * 255 = 18
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10), // Daha az padding
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ), // Küçük ikon
              ),
              const SizedBox(height: 10), // Daha az spacing
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w600,
                  fontSize: 15, // Küçük font
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
