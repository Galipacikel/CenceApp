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
