import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wizzy/core/constants/app_colors.dart';

class WizzySplashScreen extends StatefulWidget {
  const WizzySplashScreen({super.key});
  @override
  State<WizzySplashScreen> createState() => _WizzySplashScreenState();
}

class _WizzySplashScreenState extends State<WizzySplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
              ),
              child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover)),
            ),
            const SizedBox(height: 20),
            const Text("WIZZY 2026", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 5)),
          ],
        ),
      ),
    );
  }
}
