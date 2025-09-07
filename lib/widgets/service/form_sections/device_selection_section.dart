import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// devices provider import removed; using inventoryProvider for live devices
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/entry_mode_and_dates.dart';
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

    // Device search query and results
    final query = deviceSearchController.text;
    // Kaynak: inventoryProvider (stok ekranındaki anlık güncellemeleri de yansıtır)
    final invAsync = ref.watch(inventoryProvider);
    final selectedDevice = formState.activeTabData.selectedDevice;
    final filteredDevices = invAsync.maybeWhen(
      data: (invState) {
        final devices = invState.devices;
        final q = query.trim().toLowerCase();
        final manual = ref.watch(manualEntryProvider);
        // Otomatik girişte stokta olmayan cihazlar listelenmesin (remote güncel state)
        final baseList = manual ? devices : devices.where((d) => d.stockQuantity > 0).toList();
        // If no query, show all devices
        if (q.isEmpty) return baseList;
        // If a device is already selected and the query equals that selection's model or serial,
        // show all devices again so that the user can easily change their selection.
        if (selectedDevice != null &&
            (q == selectedDevice.modelName.toLowerCase() ||
             q == selectedDevice.serialNumber.toLowerCase())) {
          return baseList;
        }
        return baseList
            .where(
              (d) => d.modelName.toLowerCase().contains(q) ||
                  d.serialNumber.toLowerCase().contains(q) ||
                  d.customer.toLowerCase().contains(q),
            )
            .toList();
      },
      orElse: () => const <Device>[],
    );
    final isLoadingDevices = invAsync.isLoading;

    final manual = ref.watch(manualEntryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E6EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giriş Yöntemi Seçin',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manuel giriş: Stokta olmayan cihaz için (stok etkisi yok)\nOtomatik giriş: Stoktaki cihaz seçimi (stok miktarı azalır)',
                style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(manualEntryProvider.notifier).state = true,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: manual ? const Color(0xFF23408E) : Colors.white,
                        side: const BorderSide(color: Color(0xFF23408E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Manuel Giriş',
                        style: TextStyle(
                          color: manual ? Colors.white : const Color(0xFF23408E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(manualEntryProvider.notifier).state = false,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: manual ? Colors.white : const Color(0xFF23408E),
                        side: const BorderSide(color: Color(0xFF23408E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Otomatik Giriş',
                        style: TextStyle(
                          color: manual ? const Color(0xFF23408E) : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cihaz Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),

        if (!manual) ...[
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
        ],

        if (!manual && showDeviceSuggestions.value)
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
            child: isLoadingDevices
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(),
                  ))
                : filteredDevices.isEmpty
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
                          // Otomatik doldurma: serial/institution_name/brand/model
                          serialNumberController.text = d.serialNumber;
                          deviceNameController.text = d.customer;
                          final i = d.modelName.indexOf(' ');
                          final brand = i == -1 ? d.modelName : d.modelName.substring(0, i).trim();
                          final model = i == -1 ? '' : d.modelName.substring(i + 1).trim();
                          brandController.text = brand;
                          modelController.text = model;
                        },
                      );
                    },
                  ),
          ),

        if (!manual && selectedDevice != null) ...[
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
