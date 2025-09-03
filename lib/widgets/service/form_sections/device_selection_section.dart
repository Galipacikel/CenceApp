import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cence_app/features/devices/presentation/providers.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';

class DeviceSelectionSection extends HookConsumerWidget {
  const DeviceSelectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(newServiceFormProvider);
    final notifier = ref.read(newServiceFormProvider.notifier);
    final isInstallation = formState.formTipi == 0;

    // Hooks-based controllers
    final deviceSearchController = useTextEditingController();
    final serialNumberController = useTextEditingController(text: formState.activeTabData.serialNumber ?? '');
    final deviceNameController = useTextEditingController(text: formState.activeTabData.deviceName ?? '');
    final brandController = useTextEditingController(text: formState.activeTabData.brand ?? '');
    final modelController = useTextEditingController(text: formState.activeTabData.model ?? '');

    final showDeviceSuggestions = useState<bool>(false);

    // Device search query and results
    final query = deviceSearchController.text;
    final filteredDevices = ref.watch(devicesSearchProvider(query));
    final selectedDevice = formState.activeTabData.selectedDevice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cihaz Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),

        if (!isInstallation) ...[
          const Text(
            'Cihaz Seç',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(height: 4),
        ],
        if (!isInstallation)
          TextField(
            controller: deviceSearchController,
            keyboardType: TextInputType.text,
            onTap: () => showDeviceSuggestions.value = true,
            onChanged: (_) => showDeviceSuggestions.value = true,
            decoration: InputDecoration(
              hintText: 'Cihaz ara (model veya seri no)',
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
                        showDeviceSuggestions.value = false;
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
        if (!isInstallation) const SizedBox(height: 8),

        if (!isInstallation && showDeviceSuggestions.value)
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
                        title: Text(d.modelName),
                        subtitle: Text(d.serialNumber),
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

        if (!isInstallation && selectedDevice != null) ...[
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
                Text('Model: ${selectedDevice.modelName}'),
                Text('Seri No: ${selectedDevice.serialNumber}'),
              ],
            ),
          ),
        ],

        if (isInstallation) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0E2FF)),
            ),
            child: const Text(
              'Kurulum formu: Mevcut cihaz seçmeden aşağıdaki alanları doldurun.',
              style: TextStyle(fontSize: 12, color: Color(0xFF23408E)),
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
          onChanged: (v) => notifier.updateDeviceFields(serialNumber: v),
          decoration: InputDecoration(
            hintText: 'Cihaz seri numarasını girin',
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
          onChanged: (v) => notifier.updateDeviceFields(deviceName: v),
          decoration: InputDecoration(
            hintText: 'Cihaz adını girin',
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
          onChanged: (v) => notifier.updateDeviceFields(brand: v),
          decoration: InputDecoration(
            hintText: 'Cihaz markasını girin',
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
          onChanged: (v) => notifier.updateDeviceFields(model: v),
          decoration: InputDecoration(
            hintText: 'Cihaz modelini girin',
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
