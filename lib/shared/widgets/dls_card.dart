import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DlsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon; // CHANGÉ EN DYNAMIC
  final Color color;
  final String rating;
  final VoidCallback onTap;

  const DlsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10, bottom: -10,
                child: Opacity(
                  opacity: 0.05,
                  child: icon is IconData 
                    ? Icon(icon as IconData, size: 60, color: color) 
                    : FaIcon(icon as FaIconData, size: 60, color: color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rating, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
                        icon is IconData 
                          ? Icon(icon as IconData, color: color, size: 16) 
                          : FaIcon(icon as FaIconData, color: color, size: 16),
                      ],
                    ),
                    const Spacer(),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(subtitle, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
