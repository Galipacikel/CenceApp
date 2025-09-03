import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/device.dart';

class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<bool> Function()? onDeleteConfirm; // true dönerse sil

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    required this.onEdit,
    this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(device.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            icon: Icons.edit_note_rounded,
            label: 'Düzenle',
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: (context) async {
              if (onDeleteConfirm == null) return;
              final ok = await onDeleteConfirm!();
              if (!ok) return;
            },
            backgroundColor: AppColors.criticalRed,
            foregroundColor: Colors.white,
            icon: Icons.delete_forever_rounded,
            label: 'Sil',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueWithOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              color: AppColors.primaryBlue,
              size: 26,
            ),
          ),
          title: Text(
            device.modelName,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'ID: ${device.id} | Seri No: ${device.serialNumber}',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AppColors.subtitleColor,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.iconColor,
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
