import 'package:flutter/material.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/constants/app_colors.dart';

class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        leading: const Icon(
          Icons.devices_other,
          color: AppColors.primaryBlue,
        ),
        title: Text(
          device.modelName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Seri No: ${device.serialNumber} | Adet: ${device.stockQuantity}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.criticalRed),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: AppColors.criticalRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
