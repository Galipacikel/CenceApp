import 'package:flutter/material.dart';
import '../../../models/device.dart';

  class DeviceSelectionSection extends StatelessWidget {
    final TextEditingController deviceSearchController;
    final TextEditingController serialNumberController;
    final TextEditingController deviceNameController;
    final TextEditingController brandController;
    final TextEditingController modelController;
    final Device? selectedDevice;
    final List<Device> filteredDevices;
    final bool showDeviceSuggestions;
    final Function(String) onFilterDevices;
    final Function(Device) onSelectDevice;
    final VoidCallback onClearDevice;
    final VoidCallback onShowSuggestions;
    final bool isInstallation;

    const DeviceSelectionSection({
      super.key,
      required this.deviceSearchController,
      required this.serialNumberController,
      required this.deviceNameController,
      required this.brandController,
      required this.modelController,
      required this.selectedDevice,
      required this.filteredDevices,
      required this.showDeviceSuggestions,
      required this.onFilterDevices,
      required this.onSelectDevice,
      required this.onClearDevice,
      required this.onShowSuggestions,
      this.isInstallation = false,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cihaz Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),

        // Cihaz Seç (Arama) - Kurulumda gizle
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
            onTap: onShowSuggestions,
            onChanged: onFilterDevices,
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
                      onPressed: onClearDevice,
                    )
                  : null,
            ),
          ),
        if (!isInstallation) const SizedBox(height: 8),

        if (!isInstallation && showDeviceSuggestions)
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
                        onTap: () => onSelectDevice(d),
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
                Text('Model: ${selectedDevice!.modelName}'),
                Text('Seri No: ${selectedDevice!.serialNumber}'),
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

        // Seri No
        const Text(
          'Seri No',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: serialNumberController,
          keyboardType: TextInputType.text,
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

        // Cihaz Adı
        const Text(
          'Cihaz Adı',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: deviceNameController,
          keyboardType: TextInputType.text,
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

        // Marka
        const Text(
          'Marka',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: brandController,
          keyboardType: TextInputType.text,
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

        // Model
        const Text(
          'Model',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: modelController,
          keyboardType: TextInputType.text,
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
