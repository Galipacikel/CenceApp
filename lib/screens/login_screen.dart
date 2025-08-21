import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_paths.dart';
import '../services/username_auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final UsernameAuthService _usernameAuth = UsernameAuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Mock giriş metodu - Firebase Authentication'ı bypass eder
  Future<void> _mockLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock kullanıcı bilgileri
      final mockUser = AppUser(
        uid: 'mock-user-123',
        email: 'demo@cence.com',
        username: 'demo_user',
        fullName: 'Demo Kullanıcı',
        role: 'technician',
        isAdminFlag: false,
        createdAt: DateTime.now(),
      );

      // Provider'ı güncelle
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.updateCurrentUser(mockUser);
      }

      // Ana sayfaya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔑 Mock giriş başarılı! Demo modunda çalışıyorsunuz.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mock giriş hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı ve şifre zorunludur.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await _usernameAuth.signInWithUsername(
        username: username,
        password: password,
      );

      final uid = credential?.user?.uid;
      if (uid != null) {
        try {
          final usersRef =
              FirebaseFirestore.instance.collection(FirestorePaths.users);
          final userRef = usersRef.doc(uid);
          final userDoc = await userRef.get();

          // Kullanıcının girdiği değer email gibi mi?
          final bool inputLooksLikeEmail =
              RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,}$')
                  .hasMatch(username);

          if (!userDoc.exists) {
            final dataToSet = <String, dynamic>{
              'email': credential?.user?.email,
              'full_name': credential?.user?.displayName ?? '',
              'role': 'technician',
              'is_admin': false,
              'created_at': FieldValue.serverTimestamp(),
            };
            if (!inputLooksLikeEmail) {
              dataToSet['username'] = username;
              dataToSet['username_lowercase'] = username.toLowerCase();
            }
            await userRef.set(dataToSet, SetOptions(merge: true));
          } else {
            // Eksikse kullanıcı adını ekle (migrasyon için)
            final data = userDoc.data() as Map<String, dynamic>;
            if (!(data.containsKey('username') && data['username'] != null) &&
                !inputLooksLikeEmail) {
              await userRef.set({
                'username': username,
                'username_lowercase': username.toLowerCase(),
              }, SetOptions(merge: true));
            }
            // is_admin alanı yoksa rol'e göre varsayılan ata
            if (!data.containsKey('is_admin')) {
              final bool isAdmin = (data['role'] == 'admin');
              await userRef.set({'is_admin': isAdmin}, SetOptions(merge: true));
            }
          }
        } on FirebaseException catch (e) {
          debugPrint('User doc read/create error: ${e.code} - ${e.message}');
        }
      }

      // Provider'ı güncelle: current user ve userProfile'ı yükle
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final authService = AuthService();
        final appUser = await authService.getCurrentUserProfile();
        appState.updateCurrentUser(appUser);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Giriş yapılamadı';
      switch (e.code) {
        case 'user-not-found':
          message = 'Kullanıcı adı bulunamadı';
          break;
        case 'wrong-password':
          message = 'Şifre hatalı';
          break;
        default:
          message = e.message ?? message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF23408E).withOpacity(0.1),
                  const Color(0xFF23408E).withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Dekoratif şekiller
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF23408E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF23408E).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Ana içerik
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo ve başlık
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Logo container
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF23408E,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medical_services_rounded,
                                  size: isWide ? 48 : 40,
                                  color: const Color(0xFF23408E),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Cence yazısı
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Ce',
                                      style: TextStyle(
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'n',
                                      style: TextStyle(
                                        color: Color(0xFF23408E),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'ce',
                                      style: TextStyle(
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'Teknik Servis Yönetimi',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Giriş formu
                              _buildLoginForm(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Alt bilgi
                        Column(
                          children: [
                            Text(
                              'Cence Medikal Cihazlar',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Kullanıcı adı
        _buildTextField(
          controller: _usernameController,
          hintText: 'Kullanıcı Adı',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),

        // Şifre
        _buildTextField(
          controller: _passwordController,
          hintText: 'Şifre',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: _obscurePassword,
          onTogglePassword: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 24),

        // Giriş butonu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23408E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Mock Giriş Butonu (Geliştirme için)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _mockLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '🔑 Mock Giriş (Demo)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: const Color(0xFF23408E)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
