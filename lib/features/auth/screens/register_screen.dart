import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Contrôleurs
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Fonction d'inscription par Email
  void _handleEmailRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
        );
        // Le StreamBuilder dans main.dart redirigera vers Home automatiquement
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}"), backgroundColor: Colors.redAccent),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Fonction Google Sign-In
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google : $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // LOGO
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryPurple, width: 2),
                ),
                child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover)),
              ),
              const SizedBox(height: 20),
              const Text("REJOINDRE WIZZY", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const Text("Gagne des points, remporte le tirage !", style: TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 40),

              // BOUTON GOOGLE
              _buildSocialButton(
                label: "Continuer avec Google",
                icon: FontAwesomeIcons.google,
                onTap: _handleGoogleSignIn,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Text("OU PAR EMAIL", style: TextStyle(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.bold)),
              ),

              // CHAMPS FORMULAIRE
              _buildTextField(
                controller: _usernameController,
                hint: "Pseudo de champion",
                icon: Icons.person_outline,
                validator: (v) => v!.length < 3 ? "Pseudo trop court" : null,
              ),
              _buildTextField(
                controller: _whatsappController,
                hint: "WhatsApp (ex: +22960000000)",
                icon: FontAwesomeIcons.whatsapp,
                validator: (v) => !v!.contains("+") ? "Format international requis (+229...)" : null,
              ),
              _buildTextField(
                controller: _emailController,
                hint: "Email",
                icon: Icons.alternate_email,
                validator: (v) => !v!.contains("@") ? "Email invalide" : null,
              ),
              _buildTextField(
                controller: _passwordController,
                hint: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => v!.length < 6 ? "6 caractères minimum" : null,
              ),

              const SizedBox(height: 30),

              // BOUTON INSCRIPTION
              GestureDetector(
                onTap: _isLoading ? null : _handleEmailRegister,
                child: Container(
                  width: double.infinity, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryPurple, Color(0xFF9D50BB)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 15)],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CRÉER MON COMPTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.accentYellow, size: 18),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white24),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1)),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}