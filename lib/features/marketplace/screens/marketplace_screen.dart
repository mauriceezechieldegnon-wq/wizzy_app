import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../models/product_model.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  // Fonction pour contacter le vendeur sur WhatsApp
  void _contactSeller(Product product) async {
    final message =
        "Bonjour, je suis intéressé par l'article ${product.name} vu sur WIZZY.";
    final url =
        "https://wa.me/${product.sellerWhatsApp}?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Impossible d'ouvrir WhatsApp");
      }
    } catch (e) {
      debugPrint("Erreur WhatsApp : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LE BAZAR 🛍️",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Le Bazar est vide...",
                  style: TextStyle(color: Colors.white54)),
            );
          }

          final products = snapshot.data!.docs
              .map((doc) => Product.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                // --- ICI LA CORRECTION DE L'ERRORBUILDER ---
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white10,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white24, size: 40),
                  );
                },
                // -------------------------------------------
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${p.price} F",
                    style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _contactSeller(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    minimumSize: const Size(double.infinity, 35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("ACHETER",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
