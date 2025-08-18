import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  XFile? _profileImage;
  Uint8List? _profileImageBytes;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppStateProvider>(
      context,
      listen: false,
    ).userProfile;
    _nameController = TextEditingController(
      text: capitalizeEachWord(user?.name ?? ''),
    );
    _surnameController = TextEditingController(
      text: capitalizeEachWord(user?.surname ?? ''),
    );
    _titleController = TextEditingController(
      text: capitalizeEachWord(user?.title ?? ''),
    );
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF23408E),
              ),
              title: const Text('Kamerayla Çek'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF23408E),
              ),
              title: const Text('Galeriden Seç'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _profileImage = picked;
          _profileImageBytes = bytes;
        });
      }
    }
  }

  String capitalizeEachWord(String value) {
    return value
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    // final Color lightBlue = const Color(0xFF64B5F6);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    // final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    // final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Düzenle',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: primaryBlue,
                          child: ClipOval(
                            child: (_profileImageBytes != null)
                                ? Image.memory(
                                    _profileImageBytes!,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.edit, color: primaryBlue, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileEditField(
                    label: 'Ad',
                    hint: 'Adınızı girin',
                    controller: _nameController,
                    onChanged: (val) {
                      final fixed = capitalizeEachWord(val);
                      if (fixed != val) {
                        final pos = _nameController.selection;
                        _nameController.value = TextEditingValue(
                          text: fixed,
                          selection: pos.copyWith(
                            baseOffset: fixed.length,
                            extentOffset: fixed.length,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileEditField(
                    label: 'Soyad',
                    hint: 'Soyadınızı girin',
                    controller: _surnameController,
                    onChanged: (val) {
                      final fixed = capitalizeEachWord(val);
                      if (fixed != val) {
                        final pos = _surnameController.selection;
                        _surnameController.value = TextEditingValue(
                          text: fixed,
                          selection: pos.copyWith(
                            baseOffset: fixed.length,
                            extentOffset: fixed.length,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileEditField(
                    label: 'Unvan',
                    hint: 'Unvanınızı girin',
                    controller: _titleController,
                    onChanged: (val) {
                      final fixed = capitalizeEachWord(val);
                      if (fixed != val) {
                        final pos = _titleController.selection;
                        _titleController.value = TextEditingValue(
                          text: fixed,
                          selection: pos.copyWith(
                            baseOffset: fixed.length,
                            extentOffset: fixed.length,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileEditField(
                    label: 'E-posta',
                    hint: 'E-posta adresinizi girin',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  _ProfileEditField(
                    label: 'Telefon',
                    hint: 'Telefon numaranızı girin',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 16),
                  _ProfileEditField(
                    label: 'Departman',
                    hint: 'Departmanınızı girin',
                    controller: _departmentController,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final appState = Provider.of<AppStateProvider>(
                            context,
                            listen: false,
                          );
                          final user = appState.userProfile;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kullanıcı profili yüklenmedi. Lütfen tekrar deneyin.'),
                              ),
                            );
                            return;
                          }
                          final fixedName = capitalizeEachWord(
                            _nameController.text.trim(),
                          );
                          final fixedSurname = capitalizeEachWord(
                            _surnameController.text.trim(),
                          );
                          final fixedTitle = capitalizeEachWord(
                            _titleController.text.trim(),
                          );
                          appState.updateUserProfile(
                            user.copyWith(
                              name: fixedName,
                              surname: fixedSurname,
                              title: fixedTitle,
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              department: _departmentController.text.trim(),
                              profileImagePath:
                                  _profileImage?.path ?? user.profileImagePath,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil başarıyla güncellendi!'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.montserrat(
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
        ],
      ),
    );
  }
}

class _ProfileEditField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _ProfileEditField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return '$label boş olamaz';

            // E-posta validasyonu
            if (label == 'E-posta') {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(val.trim())) {
                return 'Geçerli bir e-posta adresi girin';
              }
            }

            // Telefon validasyonu
            if (label == 'Telefon') {
              final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
              if (!phoneRegex.hasMatch(val.trim())) {
                return 'Geçerli bir telefon numarası girin';
              }
            }

            // Ad, Soyad, Unvan, Departman için büyük harf kontrolü
            if (['Ad', 'Soyad', 'Unvan', 'Departman'].contains(label)) {
              final fixed = val
                  .split(' ')
                  .map((word) {
                    if (word.isEmpty) return word;
                    return word[0].toUpperCase() +
                        word.substring(1).toLowerCase();
                  })
                  .join(' ');
              if (val != fixed) return 'Her kelimenin ilk harfi büyük olmalı';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: subtitleColor.withOpacity(0.7),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
