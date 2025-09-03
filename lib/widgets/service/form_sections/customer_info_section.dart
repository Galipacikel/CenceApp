import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';

class CustomerInfoSection extends ConsumerStatefulWidget {
  const CustomerInfoSection({super.key});

  @override
  ConsumerState<CustomerInfoSection> createState() => _CustomerInfoSectionState();
}

class _CustomerInfoSectionState extends ConsumerState<CustomerInfoSection> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = ref.read(newServiceFormProvider).activeTabData;
    _companyController.text = t.company ?? '';
    _locationController.text = t.location ?? '';

    // Listen provider changes to keep controllers in sync
    ref.listen(newServiceFormProvider, (prev, next) {
      final nt = next.activeTabData;
      if (_companyController.text != (nt.company ?? '')) {
        _companyController.text = nt.company ?? '';
      }
      if (_locationController.text != (nt.location ?? '')) {
        _locationController.text = nt.location ?? '';
      }
    });
  }

  @override
  void dispose() {
    _companyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Müşteri/Kurum Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),

        // Firma
        const Text(
          'Firma',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField
        (
          controller: _companyController,
          keyboardType: TextInputType.text,
          onChanged: (v) {
            try {
              ref.read(newServiceFormProvider.notifier).updateDeviceFields(company: v);
            } catch (_) {}
          },
          decoration: InputDecoration(
            hintText: 'Firma adını girin',
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
        const SizedBox(height: 12),

        // Lokasyon
        const Text(
          'Lokasyon',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _locationController,
          keyboardType: TextInputType.text,
          onChanged: (v) {
            try {
              ref.read(newServiceFormProvider.notifier).updateDeviceFields(location: v);
            } catch (_) {}
          },
          decoration: InputDecoration(
            hintText: 'Lokasyon bilgisini girin',
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
      ],
    );
  }
}
