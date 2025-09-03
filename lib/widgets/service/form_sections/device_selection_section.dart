import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cence_app/features/devices/presentation/providers.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';

class DeviceSelectionSection extends HookConsumerWidget {
  const DeviceSelectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(newServiceFormProvider);
    final notifier = ref.read(newServiceFormProvider.notifier);

    // Hooks-based controllers
    final deviceSearchController = useTextEditingController();
    final serialNumberController = useTextEditingController(text: formState.activeTabData.serialNumber ?? '');
    final deviceNameController = useTextEditingController(text: formState.activeTabData.deviceName ?? '');
    final brandController = useTextEditingController(text: formState.activeTabData.brand ?? '');
    final modelController = useTextEditingController(text: formState.activeTabData.model ?? '');

    final showDeviceSuggestions = useState<bool>(false);

    // Sekme değişimlerinde veya state güncellemelerinde controller'ları aktif sekmenin verisi ile senkronize et
    ref.listen(newServiceFormProvider, (prev, next) {
      final nt = next.activeTabData;
      if (serialNumberController.text != (nt.serialNumber ?? '')) {
        serialNumberController.text = nt.serialNumber ?? '';
      }
      if (deviceNameController.text != (nt.deviceName ?? '')) {
        deviceNameController.text = nt.deviceName ?? '';
      }
      if (brandController.text != (nt.brand ?? '')) {
        brandController.text = nt.brand ?? '';
      }
      if (modelController.text != (nt.model ?? '')) {
        modelController.text = nt.model ?? '';
      }
  
      final prevSel = prev?.activeTabData.selectedDevice;
      final nextSel = nt.selectedDevice;
      final tabChanged = prev?.formTipi != next.formTipi;
      // Sekme değiştiyse veya seçili cihaz değiştiyse arama alanını güncelle
      if (tabChanged || (prevSel?.serialNumber != nextSel?.serialNumber)) {
        deviceSearchController.text = nextSel?.modelName ?? '';
        if (nextSel != null) {
          showDeviceSuggestions.value = false;
        } else {
          // Sekme değişiminde önceki sekmeden kalan query görünmesin
          if (tabChanged) {
            showDeviceSuggestions.value = false;
          }
        }
      }
    });
    // Device search query and results
    final query = deviceSearchController.text;
    // Watch all devices to build a more flexible suggestion logic
    final asyncDevices = ref.watch(devicesListProvider);
    final selectedDevice = formState.activeTabData.selectedDevice;
    final filteredDevices = asyncDevices.maybeWhen(
      data: (devices) {
        final q = query.trim().toLowerCase();
        // If no query, show all devices
        if (q.isEmpty) return devices;
        // If a device is already selected and the query equals that selection's model or serial,
        // show all devices again so that the user can easily change their selection.
        if (selectedDevice != null &&
            (q == selectedDevice.modelName.toLowerCase() ||
             q == selectedDevice.serialNumber.toLowerCase())) {
          return devices;
        }
        return devices
            .where(
              (d) => d.modelName.toLowerCase().contains(q) ||
                  d.serialNumber.toLowerCase().contains(q) ||
                  d.customer.toLowerCase().contains(q),
            )
            .toList();
      },
      orElse: () => const <Device>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cihaz Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),

        const Text(
            'Cihaz Seç',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(height: 4),
        TextField(
            controller: deviceSearchController,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: Colors.black87),
            onTap: () => showDeviceSuggestions.value = true,
            onChanged: (_) => showDeviceSuggestions.value = true,
            decoration: InputDecoration(
              hintText: 'Cihaz ara (model veya seri no)',
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
              suffixIcon: (selectedDevice != null || deviceSearchController.text.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        deviceSearchController.clear();
                        showDeviceSuggestions.value = true; // yeniden listeyi göster
                        serialNumberController.clear();
                        deviceNameController.clear();
                        brandController.clear();
                        modelController.clear();
                        notifier.setSelectedDevice(null);
                      },
                    )
                  : null,
            ),
          ),
        const SizedBox(height: 8),

        if (showDeviceSuggestions.value)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: filteredDevices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Sonuç bulunamadı'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredDevices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = filteredDevices[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        title: Text(d.modelName, style: const TextStyle(color: Colors.black87)),
                        subtitle: Text(d.serialNumber, style: const TextStyle(color: Colors.black87)),
                        onTap: () {
                          notifier.setSelectedDevice(d);
                          deviceSearchController.text = d.modelName;
                          showDeviceSuggestions.value = false;
                          serialNumberController.text = d.serialNumber;
                          deviceNameController.text = d.modelName;
                          brandController.text = d.modelName;
                          modelController.text = d.modelName;
                        },
                      );
                    },
                  ),
          ),

        if (selectedDevice != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E6EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seçili Cihaz',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text('Model: ${selectedDevice.modelName}', style: const TextStyle(color: Colors.black87)),
                Text('Seri No: ${selectedDevice.serialNumber}', style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        const Text(
          'Seri No',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: serialNumberController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black87),
          readOnly: formState.formTipi == 0 && selectedDevice != null,
          onChanged: (v) => notifier.updateDeviceFields(serialNumber: v),
          decoration: InputDecoration(
            hintText: 'Cihaz seri numarasını girin',
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
        const SizedBox(height: 12),

        const Text(
          'Cihaz Adı',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: deviceNameController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black87),
          readOnly: formState.formTipi == 0 && selectedDevice != null,
          onChanged: (v) => notifier.updateDeviceFields(deviceName: v),
          decoration: InputDecoration(
            hintText: 'Cihaz adını girin',
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
        const SizedBox(height: 12),

        const Text(
          'Marka',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: brandController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black87),
          readOnly: formState.formTipi == 0 && selectedDevice != null,
          onChanged: (v) => notifier.updateDeviceFields(brand: v),
          decoration: InputDecoration(
            hintText: 'Cihaz markasını girin',
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
        const SizedBox(height: 12),

        const Text(
          'Model',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: modelController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black87),
          readOnly: formState.formTipi == 0 && selectedDevice != null,
          onChanged: (v) => notifier.updateDeviceFields(model: v),
          decoration: InputDecoration(
            hintText: 'Cihaz modelini girin',
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
      ],
    );
  }
}
