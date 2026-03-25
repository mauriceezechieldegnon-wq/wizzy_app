import 'package:flutter/material.dart';
import 'dart:async';

class WizzySplashScreen extends StatefulWidget {
  const WizzySplashScreen({super.key});

  @override
  State<WizzySplashScreen> createState() => _WizzySplashScreenState();
}

class _WizzySplashScreenState extends State<WizzySplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redirection vers l'accueil après 4 secondes
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // NOIR PROFOND WIZZY
      body: Stack(
        children: [
          // Aura lumineuse derrière le logo
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 4),

              // LOGO AVEC ROGNAGE PROPRE
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "WIZZY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // INFOS COPYRIGHT MAURICE
              Text(
                "BY MAURICE EZÉCHIËL",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Copyright March 2026",
                style: TextStyle(
                  color: Colors.white10,
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
