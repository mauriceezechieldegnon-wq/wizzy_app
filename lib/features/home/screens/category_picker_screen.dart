import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wizzy/features/quiz/screens/quiz_screen.dart';
// ignore: unused_import
import '../../core/constants/app_colors.dart';

class CategoryPickerScreen extends StatelessWidget {
  const CategoryPickerScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      "name": "SPORT",
      "icon": FontAwesomeIcons.futbol,
      "color": Colors.greenAccent
    },
    {
      "name": "TECHNOLOGIE",
      "icon": FontAwesomeIcons.microchip,
      "color": Colors.blueAccent
    },
    {
      "name": "GÉOGRAPHIE",
      "icon": FontAwesomeIcons.globe,
      "color": Colors.orangeAccent
    },
    {
      "name": "HISTOIRE",
      "icon": FontAwesomeIcons.landmark,
      "color": Colors.redAccent
    },
    {
      "name": "SCIENCE",
      "icon": FontAwesomeIcons.flask,
      "color": Colors.purpleAccent
    },
    {
      "name": "GAMING",
      "icon": FontAwesomeIcons.gamepad,
      "color": Colors.pinkAccent
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("CHOISIS TON THÈME",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _buildCategoryCard(context, cat);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(category: cat['name']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: (cat['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: (cat['color'] as Color).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], color: cat['color'], size: 30),
            const SizedBox(height: 12),
            Text(cat['name'],
                style: TextStyle(
                    color: cat['color'],
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
