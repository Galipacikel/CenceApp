import 'package:flutter/material.dart';
import '../../../models/device.dart';

class DeviceSelectionSection extends StatelessWidget {
  final TextEditingController deviceSearchController;
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
        const SizedBox(height: 8),
        const Text(
          'Cihaz',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        // Responsive device selection
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: deviceSearchController,
                  readOnly: false,
                  decoration: InputDecoration(
                    hintText: 'Model, seri numarası veya müşteri...',
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
                    suffixIcon: selectedDevice != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: onClearDevice,
                          )
                        : null,
                  ),
                  onChanged: onFilterDevices,
                  onTap: onShowSuggestions,
                ),
                if (showDeviceSuggestions && filteredDevices.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight > 300
                          ? 300
                          : constraints.maxHeight * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, index) {
                        final device = filteredDevices[index];
                        return ListTile(
                          title: Text(
                            '${device.modelName} (${device.serialNumber})',
                          ),
                          onTap: () => onSelectDevice(device),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
