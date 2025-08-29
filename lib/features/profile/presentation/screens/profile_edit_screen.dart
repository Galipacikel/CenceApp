import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  XFile? _profileImage;
  Uint8List? _profileImageBytes;
  final _formKey = GlobalKey<FormState>();
  String? _savedProfileImagePath;

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImagePath();
  }

  Future<void> _loadSavedProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _savedProfileImagePath = prefs.getString('profile_image_path');
      });
    }
  }

  @override
  void dispose() {
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
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final double cardRadius = 18;

    final asyncUser = ref.watch(appUserProvider);

    String name = '';
    String surname = '';
    String titleStr = '';

    asyncUser.whenData((u) {
      final fullName = u?.fullName ?? '';
      final parts = fullName.trim().split(RegExp(r"\s+"));
      name = parts.isNotEmpty ? capitalizeEachWord(parts.first) : '';
      surname = parts.length > 1
          ? capitalizeEachWord(parts.sublist(1).join(' '))
          : '';
      titleStr = (u?.isAdmin ?? false) ? 'Admin' : 'Teknisyen';
    });

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Bilgileri',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
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
                  color: Colors.black.withAlpha(15),
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
                          backgroundImage: _profileImageBytes != null
                              ? null
                              : (_savedProfileImagePath != null
                                    ? FileImage(File(_savedProfileImagePath!))
                                    : null),
                          child: ClipOval(
                            child: (_profileImageBytes != null)
                                ? Image.memory(
                                    _profileImageBytes!,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                  )
                                : (_savedProfileImagePath == null
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 38,
                                        )
                                      : null),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
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
                  _ProfileInfoField(label: 'Ad', value: name),
                  const SizedBox(height: 16),
                  _ProfileInfoField(label: 'Soyad', value: surname),
                  const SizedBox(height: 16),
                  _ProfileInfoField(label: 'Unvan', value: titleStr),
                  const SizedBox(height: 28),
                  if (_profileImage != null) ...[
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          if (_profileImage != null) {
                            await prefs.setString(
                              'profile_image_path',
                              _profileImage!.path,
                            );
                            if (mounted) {
                              setState(() {
                                _savedProfileImagePath = _profileImage!.path;
                              });
                            }
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profil fotoğrafı başarıyla güncellendi!',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Fotoğrafı Kaydet',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoField({required this.label, required this.value});

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.isEmpty ? 'Belirtilmemiş' : value,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: value.isEmpty ? subtitleColor.withAlpha(179) : textColor,
            ),
          ),
        ),
      ],
    );
  }
}