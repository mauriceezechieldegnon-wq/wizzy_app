import 'package:flutter/material.dart';

class DlsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String rating; // Comme la note globale (ex: 95)
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
        padding: const EdgeInsets.all(2), // Bordure fine lumineuse
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.2)
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Fond noir de la carte
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // 1. L'effet de brillance en fond (Diagonal)
              Positioned(
                top: -20,
                right: -20,
                child:
                    Icon(icon, size: 80, color: color.withValues(alpha: 0.1)),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Le Header de la carte (Note + Icone)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rating,
                              style: TextStyle(
                                color: color,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            Text(
                              "LVL",
                              style: TextStyle(
                                  color: color,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(icon, color: color, size: 20),
                      ],
                    ),
                    const Spacer(),
                    // 3. Le Nom et la Catégorie
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            color: color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. La petite barre de stat en bas (Style DLS)
              Positioned(
                bottom: 8,
                right: 12,
                child: Row(
                  children: [
                    _miniStat("VITE", "99"),
                    const SizedBox(width: 5),
                    _miniStat("INT", "95"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 6)),
      ],
    );
  }
}
