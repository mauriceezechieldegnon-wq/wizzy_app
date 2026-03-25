import 'package:flutter/material.dart';

class DlsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
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
        padding: const EdgeInsets.all(1.5), // L'effet de bordure néon
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
            color: const Color(0xFF121212), // Fond de la carte
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              // Filigrane en fond
              Positioned(
                right: -10,
                bottom: -10,
                child:
                    Icon(icon, size: 60, color: color.withValues(alpha: 0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating + Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rating,
                            style: TextStyle(
                                color: color,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        Icon(icon, color: color, size: 16),
                      ],
                    ),
                    const Text("RANK",
                        style: TextStyle(
                            color: Colors.white24,
                            fontSize: 7,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    // Titre
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                    // Badge Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(subtitle,
                          style: TextStyle(
                              color: color,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              // Stats en bas à droite (Style DLS)
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    _stat("XP", "99"),
                    const SizedBox(width: 4),
                    _stat("IQ", "95"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String val) => Column(
        children: [
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white24, fontSize: 5)),
        ],
      );
}
