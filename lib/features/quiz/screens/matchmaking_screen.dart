import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  int selectedMise = 10;
  bool searching = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  void startSearch() {
    setState(() => searching = true);
    _controller.repeat();
    // Simulation de recherche de 4 secondes
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => searching = false);
        _controller.stop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Adversaire trouvé ! (Prochainement)")));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const BackButton(color: Colors.white)),
      body: Center(
        child: searching ? _buildRadar() : _buildSelection(),
      ),
    );
  }

  Widget _buildSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("CHOISIS TA MISE",
            style: TextStyle(
                color: AppColors.accentYellow,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [10, 50, 100]
              .map((m) => GestureDetector(
                    onTap: () => setState(() => selectedMise = m),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: selectedMise == m
                              ? AppColors.primaryPurple
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selectedMise == m
                                  ? AppColors.accentYellow
                                  : Colors.transparent)),
                      child: Text("$m PTS",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
            onPressed: startSearch,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple),
            child: const Text("TROUVER UN RIVAL")),
      ],
    );
  }

  Widget _buildRadar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primaryPurple
                    .withValues(alpha: 1 - _controller.value),
                width: 4),
          ),
          child: const Center(
              child: Text("RECHERCHE...",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        );
      },
    );
  }
}
