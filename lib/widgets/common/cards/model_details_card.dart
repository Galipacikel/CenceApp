import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/device.dart';

class ModelDetailsCard extends StatelessWidget {
  final String modelName;
  final List<Device> devices;
  final ValueChanged<Device> onDeviceTap;

  const ModelDetailsCard({
    super.key,
    required this.modelName,
    required this.devices,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalDevices = devices.length;
    final activeWarranty = devices
        .where(
          (d) =>
              d.warrantyEndDate != null &&
              d.calculatedWarrantyStatus == 'Devam Ediyor',
        )
        .length;
    final expiredWarranty = totalDevices - activeWarranty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF23408E).withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.devices_other_rounded,
                  color: Color(0xFF23408E),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modelName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalDevices cihaz satılmış',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$activeWarranty',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: const Color(0xFF43A047),
                        ),
                      ),
                      Text(
                        'Aktif Garanti',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xFF43A047),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$expiredWarranty',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Garanti Bitti',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Satılan Müşteriler',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...devices.map(
            (device) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: device.warrantyEndDate != null
                        ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                              ? const Color(0xFF43A047).withAlpha(26)
                              : Colors.red.withAlpha(26))
                        : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    device.warrantyEndDate != null
                        ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                              ? Icons.verified_rounded
                              : Icons.warning_rounded)
                        : Icons.help_outline_rounded,
                    color: device.warrantyEndDate != null
                        ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                              ? const Color(0xFF43A047)
                              : Colors.red)
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  device.customer,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seri No: ${device.serialNumber}',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Kurulum: ${device.installDate}',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                trailing: _buildWarrantyChip(
                  device.calculatedWarrantyStatus,
                  device.daysUntilWarrantyExpiry,
                ),
                onTap: () => onDeviceTap(device),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildWarrantyChip(String status, int? daysLeft) {
  Color color;
  String label = status;
  IconData icon = Icons.verified_rounded;

  if (status == 'Devam Ediyor') {
    if (daysLeft != null && daysLeft <= 30 && daysLeft > 0) {
      color = Colors.orange.shade600;
      label = 'Az Kaldı ($daysLeft gün)';
      icon = Icons.warning_rounded;
    } else {
      color = Colors.green.shade600;
      icon = Icons.check_circle_rounded;
    }
  } else {
    color = Colors.red.shade600;
    icon = Icons.cancel_rounded;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha(77),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
