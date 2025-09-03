import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cence_app/constants/app_colors.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

class PartFormSheet extends ConsumerStatefulWidget {
  final StockPart? part; // null ise yeni ekleme, değilse düzenleme

  const PartFormSheet({
    super.key,
    this.part,
  });

  @override
  ConsumerState<PartFormSheet> createState() => _PartFormSheetState();
}

class _PartFormSheetState extends ConsumerState<PartFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController parcaAdiCtrl;
  late final TextEditingController parcaKoduCtrl;
  late final TextEditingController stokAdediCtrl;
  late final TextEditingController criticalLevelCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      // Düzenleme modu
      final part = widget.part!;
      parcaAdiCtrl = TextEditingController(text: part.parcaAdi);
      parcaKoduCtrl = TextEditingController(text: part.parcaKodu);
      stokAdediCtrl = TextEditingController(text: part.stokAdedi.toString());
      criticalLevelCtrl = TextEditingController(text: part.criticalLevel.toString());
    } else {
      // Yeni ekleme modu
      parcaAdiCtrl = TextEditingController();
      parcaKoduCtrl = TextEditingController();
      stokAdediCtrl = TextEditingController(text: '0');
      criticalLevelCtrl = TextEditingController(text: '5');
    }
  }

  @override
  void dispose() {
    parcaAdiCtrl.dispose();
    parcaKoduCtrl.dispose();
    stokAdediCtrl.dispose();
    criticalLevelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.part != null;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Parçayı Düzenle' : 'Yeni Parça Ekle',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: parcaAdiCtrl,
                label: 'Parça Adı',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: parcaKoduCtrl,
                label: 'Parça Kodu',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: stokAdediCtrl,
                label: 'Stok Adedi',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                  if (int.tryParse(v) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: criticalLevelCtrl,
                label: 'Kritik Seviye',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                  if (int.tryParse(v) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Kaydet' : 'Ekle',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator ?? (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
    );
  }

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final isEditing = widget.part != null;
    
    if (isEditing) {
      // Düzenleme
      final updatedPart = StockPart(
        id: widget.part!.id,
        parcaAdi: parcaAdiCtrl.text,
        parcaKodu: parcaKoduCtrl.text,
        stokAdedi: int.parse(stokAdediCtrl.text),
        criticalLevel: int.parse(criticalLevelCtrl.text),
      );
      
      final success = await ref.read(inventoryProvider.notifier).updatePart(updatedPart);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parça başarıyla güncellendi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Yeni ekleme
      final newPart = StockPart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        parcaAdi: parcaAdiCtrl.text,
        parcaKodu: parcaKoduCtrl.text,
        stokAdedi: int.parse(stokAdediCtrl.text),
        criticalLevel: int.parse(criticalLevelCtrl.text),
      );
      
      final success = await ref.read(inventoryProvider.notifier).addPart(newPart);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parça başarıyla eklendi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
