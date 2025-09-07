import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cence_app/constants/app_colors.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

class DeviceFormSheet extends ConsumerStatefulWidget {
  final Device? device; // null ise yeni ekleme, değilse düzenleme

  const DeviceFormSheet({
    super.key,
    this.device,
  });

  @override
  ConsumerState<DeviceFormSheet> createState() => _DeviceFormSheetState();
}

class _DeviceFormSheetState extends ConsumerState<DeviceFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController serialNumberCtrl;
  late final TextEditingController cihazAdiCtrl;
  late final TextEditingController markaCtrl;
  late final TextEditingController modelCtrl;
  late final TextEditingController stokAdediCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.device != null) {
      // Düzenleme modu
      final device = widget.device!;
      final modelNameParts = device.modelName.split(' ');
      final marka = modelNameParts.isNotEmpty ? modelNameParts.first : '';
      final model = modelNameParts.length > 1 ? modelNameParts.sublist(1).join(' ') : '';
      
      serialNumberCtrl = TextEditingController(text: device.serialNumber);
      cihazAdiCtrl = TextEditingController(text: device.customer);
      markaCtrl = TextEditingController(text: marka);
      modelCtrl = TextEditingController(text: model);
      stokAdediCtrl = TextEditingController(text: device.stockQuantity.toString());
    } else {
      // Yeni ekleme modu
      serialNumberCtrl = TextEditingController();
      cihazAdiCtrl = TextEditingController();
      markaCtrl = TextEditingController();
      modelCtrl = TextEditingController();
      stokAdediCtrl = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    serialNumberCtrl.dispose();
    cihazAdiCtrl.dispose();
    markaCtrl.dispose();
    modelCtrl.dispose();
    stokAdediCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.device != null;
    
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
                isEditing ? 'Cihazı Düzenle' : 'Yeni Cihaz Ekle',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: serialNumberCtrl,
                label: 'Seri Numarası',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: cihazAdiCtrl,
                label: 'Cihaz Adı',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: markaCtrl,
                label: 'Marka',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: modelCtrl,
                label: 'Model',
              ),
              const SizedBox(height: 16),
              if (isEditing)
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

    final isEditing = widget.device != null;
    
    if (isEditing) {
      // Düzenleme
      final updatedDevice = widget.device!.copyWith(
        serialNumber: serialNumberCtrl.text,
        modelName: '${markaCtrl.text} ${modelCtrl.text}',
        customer: cihazAdiCtrl.text,
        stockQuantity: int.parse(stokAdediCtrl.text),
      );
      
      final success = await ref.read(inventoryProvider.notifier).updateDevice(updatedDevice);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cihaz başarıyla güncellendi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Yeni ekleme
      final newDevice = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        serialNumber: serialNumberCtrl.text,
        modelName: '${markaCtrl.text} ${modelCtrl.text}',
        customer: cihazAdiCtrl.text,
        installDate: DateTime.now().toString().split(' ')[0],
        warrantyStatus: 'Devam Ediyor',
        lastMaintenance: DateTime.now().toString().split(' ')[0],
        warrantyEndDate: DateTime.now().add(const Duration(days: 365)),
        stockQuantity: 1,
      );
      
      final success = await ref.read(inventoryProvider.notifier).addDevice(newDevice);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cihaz başarıyla eklendi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
