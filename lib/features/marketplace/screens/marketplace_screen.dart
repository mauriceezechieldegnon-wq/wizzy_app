import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wizzy/core/constants/app_colors.dart';
import 'package:wizzy/features/marketplace/models/product_model.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  void _contactSeller(Product product) async {
    final message = "Bonjour, je suis intéressé par ${product.name} sur WIZZY.";
    final url = "https://wa.me/${product.sellerWhatsApp}?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 6 : (screenWidth > 800 ? 4 : 2);
    double aspectRatio = screenWidth > 800 ? 0.85 : 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LE BAZAR", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Boutique vide...", style: TextStyle(color: Colors.white24)));
          }
          final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(context, products[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity,
                errorBuilder: (context, error, stack) => const Icon(Icons.image, color: Colors.white10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("${p.price} F", style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _contactSeller(p),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, minimumSize: const Size(double.infinity, 30)),
                  child: const Text("ACHETER", style: TextStyle(fontSize: 9, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
