import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/stock_part.dart';

class StockPartTile extends StatelessWidget {
  final StockPart part;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<bool> Function()? onDeleteConfirm; // true dönerse sil

  const StockPartTile({
    super.key,
    required this.part,
    required this.onTap,
    required this.onEdit,
    this.onDeleteConfirm,
  });

  bool get isCritical => part.stokAdedi <= part.criticalLevel;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(part.id),
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
              color: isCritical
                  ? AppColors.criticalBackground
                  : AppColors.primaryBlueWithOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCritical ? Icons.warning_amber_rounded : Icons.memory_rounded,
              color: isCritical ? AppColors.criticalText : AppColors.primaryBlue,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  part.parcaAdi,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              if (part.stokAdedi == 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.criticalTextWithOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.criticalText, width: 1),
                  ),
                  child: Text(
                    'Stok tükendi',
                    style: GoogleFonts.montserrat(
                      color: AppColors.criticalText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
              else if (isCritical)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.criticalTextWithOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Stok kritik',
                    // Replace the text color for 'Stok kritik' label to use themed color when not critical
                    // Assuming this section is inside a widget where `isOutOfStock` is not available, fallback to themed color only
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            'Kod: ${part.parcaKodu}  |  Stok: ${part.stokAdedi}',
            style: GoogleFonts.montserrat(
              color: AppColors.subtitleColor,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(
            Icons.info_outline_rounded,
            color: AppColors.iconColor,
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}