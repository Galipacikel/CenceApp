import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_paths.dart';
import '../services/username_auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/auth_service.dart';


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
      // Eğer anonim oturum açıldıysa (kullanıcı-adı eşlemesi için), gerçek girişten önce kapat
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null && auth.currentUser!.isAnonymous) {
        await auth.signOut();
      }

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

          if (!userDoc.exists) {
            // Yetkili kullanıcılar sadece önceden tanımlanır
            await FirebaseAuth.instance.signOut();
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'Yetkisiz kullanıcı veya kullanıcı bulunamadı.',
            );
          } else {
            final data = userDoc.data() as Map<String, dynamic>;
            final bool isActive = (data['is_active'] as bool?) ?? false;
            if (!isActive) {
              await FirebaseAuth.instance.signOut();
              throw FirebaseAuthException(
                code: 'user-disabled',
                message:
                    'Hesabınız aktif değil. Lütfen yöneticinizle iletişime geçin.',
              );
            }
          }
          // Otomatik kullanıcı oluşturmayı kaldırdık; sadece önceden tanımlı ve aktif kullanıcılar giriş yapabilir.
          // Gerekli kontroller yukarıda yapılıyor.
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
          message = 'Kullanıcı adı veya e-posta bulunamadı';
          break;
        case 'wrong-password':
          message = 'Şifre hatalı';
          break;
        case 'user-disabled':
          message = 'Hesabınız devre dışı. Lütfen yöneticinizle iletişime geçin.';
          break;
        case 'too-many-requests':
          message = 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'network-request-failed':
          message = 'Ağ hatası. İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
          break;
        case 'invalid-credential':
          message = 'Geçersiz kimlik bilgileri. Bilgilerinizi kontrol edin.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta formatı.';
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
                  const Color(0xFF23408E).withAlpha(20), // 0.08 * 255 ≈ 20
                  const Color(0xFF23408E).withAlpha(13), // 0.05 * 255 ≈ 13
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
                color: const Color(0xFF23408E).withAlpha(26), // 0.1 * 255 ≈ 26
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
                color: Colors.black.withAlpha(20), // 0.08 * 255 ≈ 20
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
                                color: Colors.black.withAlpha(20), // 0.08 * 255 ≈ 20
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
                                  color: const Color(0xFF23408E).withAlpha(26),
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

        // Mock giriş kaldırıldı
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
