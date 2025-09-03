import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(appUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final displayName = asyncUser.maybeWhen(
      data: (u) {
        final name = u?.fullName ?? u?.email ?? '';
        return name.isNotEmpty ? name : 'Kullanıcı';
      },
      orElse: () => 'Kullanıcı',
    );

    return Container(
      padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF23408E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          // Sol: Logo veya Drawer ikonu
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(31), // 0.12 * 255 ≈ 31
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Orta: Uygulama adı
          const Expanded(
            child: Text(
              'Cence Medikal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Sağ: Kullanıcı adı, rolü ve profil fotoğrafı
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    isAdmin ? 'Admin' : 'Teknisyen',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, child) {
                  final prefsAsync = ref.watch(sharedPreferencesProvider);
                  
                  return prefsAsync.when(
                    data: (prefs) {
                      final profileImageUrl = prefs.getString('profile_image_url');
                      return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: profileImageUrl != null
                          ? Image.network(
                              profileImageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF23408E),
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Color(0xFF23408E),
                                  size: 20,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              color: Color(0xFF23408E),
                              size: 20,
                            ),
                    ),
                      );
                    },
                    loading: () => const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(
                        color: Color(0xFF23408E),
                        strokeWidth: 2,
                      ),
                    ),
                    error: (_, __) => const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF23408E),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
