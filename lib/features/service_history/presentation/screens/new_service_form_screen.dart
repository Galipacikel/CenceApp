import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/widgets/service/form_sections/device_selection_section.dart';
import 'package:cence_app/widgets/service/form_sections/customer_info_section.dart';
import 'package:cence_app/widgets/service/form_widgets/form_type_selection.dart';
import 'package:cence_app/widgets/service/form_widgets/submit_button.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/widgets/photo_picker.dart';
import 'package:cence_app/widgets/service/form_sections/used_parts_section.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/home/presentation/screens/home_page.dart';

class NewServiceFormScreen extends HookConsumerWidget {
  const NewServiceFormScreen({super.key});

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  String _calculateWarrantyEndDate(WidgetRef ref) {
    final t = ref.watch(newServiceFormProvider).activeTabData;
    if (t.date == null || t.warranty.isEmpty) {
      return 'Hesaplanamıyor';
    }
    try {
      final warrantyDuration = int.parse(t.warranty);
      final warrantyEndDate = DateTime(
        t.date!.year,
        t.date!.month + warrantyDuration,
        t.date!.day,
      );
      return '${warrantyEndDate.day.toString().padLeft(2, '0')}.${warrantyEndDate.month.toString().padLeft(2, '0')}.${warrantyEndDate.year}';
    } catch (_) {
      return 'Hesaplanamıyor';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(newServiceFormProvider);
    final notifier = ref.read(newServiceFormProvider.notifier);

    // Hook tabanlı controllerlar
    final descriptionController = useTextEditingController(
      text: formState.activeTabData.description ?? '',
    );
    final warrantyController = useTextEditingController(
      text: formState.activeTabData.warranty,
    );

    // App user -> teknisyen adını state'e yansıt
    ref.listen(appUserProvider, (previous, next) {
      next.when(
        data: (appUser) {
          final uname = (appUser?.username ?? appUser?.usernameLowercase ?? '')
              .trim();
          if (uname.isNotEmpty) {
            notifier.setTechnicianName(uname);
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Yeni Servis Formu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Form doldurma konusunda yardım için destek ekibimizle iletişime geçin.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Form Tipi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            const FormTypeSelection(),
            const SizedBox(height: 22),
            const DeviceSelectionSection(),
            const SizedBox(height: 22),
            const CustomerInfoSection(),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: PhotoPicker(
                    initialBytes: formState.activeTabData.photoBytes,
                    onChanged: (selection) {
                      notifier.updatePhoto(
                        bytes: selection?.bytes,
                        file: selection?.file,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'Form Detayları',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),

            const Text(
              'Kurulum Tarihi',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: formState.activeTabData.date ?? now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                  locale: const Locale('tr', 'TR'),
                );
                if (picked != null) {
                  notifier.updateDate(picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'gg.aa.yyyy',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                child: Text(
                  _formatDate(formState.activeTabData.date),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (formState.formTipi == 0) ...[
              const Text(
                'Garanti Süresi (Ay)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: warrantyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: '24',
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => notifier.updateWarranty(value),
              ),
              const SizedBox(height: 8),

              if (formState.activeTabData.date != null &&
                  warrantyController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F6ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF43A047).withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF43A047),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Garanti Bitiş Tarihi: ${_calculateWarrantyEndDate(ref)}',
                          style: const TextStyle(
                            color: Color(0xFF43A047),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const Text(
              'Teknisyen',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: useTextEditingController(text: formState.technicianName),
              readOnly: true,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Teknisyen adı otomatik doldurulur',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.person, color: Color(0xFF23408E)),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Kullanılan Parçalar (Opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),

            const UsedPartsSection(),
            const SizedBox(height: 12),

            const Text(
              'Açıklama',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: descriptionController,
              onChanged: (value) => notifier.updateDescription(value),
              keyboardType: TextInputType.text,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Yapılan işlemi ve notlarınızı buraya yazın...',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            SubmitButton(
              onSubmit: () async {
                final t = ref.read(newServiceFormProvider).activeTabData;
                final form = ref.read(newServiceFormProvider);
                
                final musteri = (t.company ?? '').trim();
                final deviceLabel = [
                  (t.deviceName ?? '').trim(),
                  (t.serialNumber ?? '').trim(),
                ].where((e) => e.isNotEmpty).join(' ').trim();
                
                if (musteri.isEmpty || deviceLabel.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen Firma ve Cihaz bilgilerini doldurun.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                
                final parts = t.selectedParts
                    .map((sp) => StockPart(
                          id: sp.part.id,
                          parcaAdi: sp.part.parcaAdi,
                          parcaKodu: sp.part.parcaKodu,
                          stokAdedi: sp.adet,
                          criticalLevel: sp.part.criticalLevel,
                        ))
                    .toList();
                
                final history = ServiceHistory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: t.date ?? DateTime.now(),
                  serialNumber: deviceLabel,
                  musteri: musteri,
                  description: ((t.description ?? '').trim().isEmpty)
                      ? '-'
                      : (t.description ?? '').trim(),
                  technician: (form.technicianName.trim().isEmpty)
                      ? '-'
                      : form.technicianName.trim(),
                  status: form.formTipi == 0 ? 'Kurulum' : 'Arıza',
                  location: (t.location ?? ''),
                  kullanilanParcalar: parts,
                  photos: const [],
                );
                
                try {
                  await notifier.saveHistoryAndDeductStock(history);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kayıt başarılı'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kayıt başarısız: $e'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
