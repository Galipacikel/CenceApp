import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/constants/app_colors.dart';

class StockPartTile extends StatelessWidget {
  final StockPart part;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockPartTile({
    super.key,
    required this.part,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = part.stokAdedi <= 0;
    final bool isCritical = !isOutOfStock && part.stokAdedi <= part.criticalLevel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? AppColors.criticalRed
              : isCritical
              ? AppColors.criticalRed.withAlpha(89)
              : AppColors.primaryBlue.withAlpha(26),
          width: isOutOfStock ? 1.5 : isCritical ? 2 : 1,
        ),
        boxShadow: [
          if (isOutOfStock)
            BoxShadow(
              color: AppColors.criticalRed.withAlpha(46),
              blurRadius: 14,
              offset: const Offset(0, 2),
            )
          else if (isCritical)
            BoxShadow(
              color: AppColors.criticalRed.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isOutOfStock
                ? AppColors.criticalRed.withAlpha(100)
                : isCritical
                ? AppColors.criticalRed.withAlpha(46)
                : AppColors.primaryBlue.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOutOfStock
                ? Icons.block
                : isCritical
                ? Icons.warning_amber_rounded
                : Icons.memory,
            color: isOutOfStock
                ? AppColors.criticalRed
                : isCritical
                ? AppColors.criticalRed
                : AppColors.primaryBlue,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                part.parcaAdi,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock ? AppColors.criticalRed : AppColors.textColor,
                  fontSize: 16,
                ),
              ),
            ),
            if (isOutOfStock)
              Text(
                'Stok tükendi',
                style: GoogleFonts.montserrat(
                  color: AppColors.criticalRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              )
            else if (isCritical)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.criticalRed.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stok kritik',
                  style: GoogleFonts.montserrat(
                    color: AppColors.criticalRed,
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
            color: isOutOfStock ? AppColors.criticalRed : AppColors.subtitleColor,
            fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
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
