import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cence_app/services/firestore_paths.dart';
import 'package:cence_app/services/username_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/features/home/presentation/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final UsernameAuthService _usernameAuth = UsernameAuthService();

  // SharedPreferences metodları
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await _clearCredentials();
    }
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }

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
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
      final auth = ref.read(firebaseAuthProvider);
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
          final usersRef = ref
              .read(firebaseFirestoreProvider)
              .collection(FirestorePaths.users);
          final userRef = usersRef.doc(uid);
          final userDoc = await userRef.get();

          if (!userDoc.exists) {
            // Yetkili kullanıcılar sadece önceden tanımlanır
            await ref.read(firebaseAuthProvider).signOut();
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'Yetkisiz kullanıcı veya kullanıcı bulunamadı.',
            );
          } else {
            final data = userDoc.data() as Map<String, dynamic>;
            final bool isActive = (data['is_active'] as bool?) ?? false;
            if (!isActive) {
              await ref.read(firebaseAuthProvider).signOut();
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

      // Başarılı giriş sonrası kullanıcı bilgilerini kaydet
      await _saveCredentials();

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
          message =
              'Hesabınız devre dışı. Lütfen yöneticinizle iletişime geçin.';
          break;
        case 'too-many-requests':
          message =
              'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'network-request-failed':
          message =
              'Ağ hatası. İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 600;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;
    
    // Responsive padding ve boyutlar
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 24.0);
    final containerMaxWidth = isDesktop ? 400.0 : (isTablet ? 500.0 : double.infinity);
    final logoSize = isDesktop ? 200.0 : (isTablet ? 180.0 : (isWide ? 180.0 : 150.0));

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
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: containerMaxWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo ve başlık
                          Container(
                            padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    20,
                                  ), // 0.08 * 255 ≈ 20
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Logo container
                                Container(
                                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF23408E).withAlpha(26),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/app_icon/cence_logo.jpeg',
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 24 : 20),

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

                           SizedBox(height: isDesktop ? 48 : 40),

                           // Alt bilgi
                           Column(
                             children: [
                               Text(
                                 'Cence Medikal Cihazlar',
                                 style: TextStyle(
                                   color: Colors.grey.shade600,
                                   fontSize: isDesktop ? 16 : 14,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                               SizedBox(height: isDesktop ? 6 : 4),
                               Text(
                                 'v1.0.0',
                                 style: TextStyle(
                                   color: Colors.grey.shade500,
                                   fontSize: isDesktop ? 14 : 12,
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
        const SizedBox(height: 16),

        // Beni Hatırla checkbox'ı
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: const Color(0xFF23408E),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                child: Text(
                  'Beni Hatırla',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: isDesktop ? 16 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF23408E),
            size: isDesktop ? 24 : 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey.shade600,
                    size: isDesktop ? 24 : 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 20 : 16,
          ),
        ),
      ),
    );
  }
}
