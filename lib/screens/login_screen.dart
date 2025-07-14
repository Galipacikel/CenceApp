import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(milliseconds: 500)); // loading efekti için
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Soft dairesel arka plan şekilleri
          Positioned(
            top: -60,
            left: -60,
            child: _buildCircle(180, Colors.grey.withOpacity(0.08)),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: _buildCircle(100, Colors.grey.withOpacity(0.10)),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _buildCircle(120, Colors.grey.withOpacity(0.12)),
          ),
          Positioned(
            bottom: 60,
            right: -50,
            child: _buildCircle(90, Colors.grey.withOpacity(0.09)),
          ),
          // Üstte slogan
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Teknik Serviste Dijital Dönüşüm',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          // Ortadaki kart ve içerik (ekranın ortasında)
          Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Teknik servis/onarım ikonu
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.build_rounded, // Teknik servis/onarım ikonu
                      color: const Color(0xFF333F50),
                      size: 38,
                    ),
                  ),
                  // Cence Logo
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'Montserrat',
                      ),
                      children: [
                        TextSpan(text: 'Ce', style: TextStyle(color: Color(0xFF1C1C1C))),
                        TextSpan(text: 'n', style: TextStyle(color: Color(0xFFE53935))),
                        TextSpan(text: 'ce', style: TextStyle(color: Color(0xFF1C1C1C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Hoş geldiniz metni
                  Text(
                    'Hoş geldiniz, lütfen giriş yapınız.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Kullanıcı Adı (email)
                  _LoginTextField(
                    controller: _emailController,
                    hintText: 'Kullanıcı Adı',
                    icon: Icons.person_outline,
                    obscureText: false,
                    validator: null,
                  ),
                  const SizedBox(height: 18),
                  // Şifre
                  _LoginTextField(
                    controller: _passwordController,
                    hintText: 'Şifre',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: null,
                  ),
                  const SizedBox(height: 18),
                  // Giriş Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333F50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Alt açıklama ve versiyon
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cence Medikal Cihazlar Teknik Servis',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const _LoginTextField({
    required this.hintText,
    required this.icon,
    required this.obscureText,
    this.controller,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Dummy ana ekran (giriş başarılıysa yönlendirme için)
class _DummyHomeScreen extends StatelessWidget {
  const _DummyHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Ekran')),
      body: const Center(child: Text('Giriş başarılı!')),
    );
  }
} 