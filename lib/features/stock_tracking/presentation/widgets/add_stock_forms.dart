import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/providers/device_provider.dart';
import 'package:cence_app/providers/stock_provider.dart';

/// Yeni parça ekleme modal bottom sheet'i gösteren widget
class AddPartSheet {
  static void show(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final parcaAdiCtrl = TextEditingController();
    final parcaKoduCtrl = TextEditingController();
    final stokAdediCtrl = TextEditingController();
    final criticalLevelCtrl = TextEditingController(text: '5');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                    'Yeni Yedek Parça Ekle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: parcaAdiCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: parcaKoduCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Kodu'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: stokAdediCtrl,
                    decoration: const InputDecoration(labelText: 'Stok Adedi'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: criticalLevelCtrl,
                    decoration: const InputDecoration(labelText: 'Kritik Seviye'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      final val = int.tryParse(v);
                      if (val == null) return 'Lütfen geçerli bir sayı girin';
                      if (val < 0) return 'Negatif değer olamaz';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final yeniParca = StockPart(
                          id: 'PART-${DateTime.now().millisecondsSinceEpoch}',
                          parcaAdi: parcaAdiCtrl.text,
                          parcaKodu: parcaKoduCtrl.text,
                          stokAdedi: int.parse(stokAdediCtrl.text),
                          criticalLevel: int.parse(criticalLevelCtrl.text),
                        );
                        Provider.of<StockProvider>(
                          context,
                          listen: false,
                        ).addPart(yeniParca);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Ekle'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Yeni cihaz stoğu ekleme modal bottom sheet'i (kritik seviye yok)
class AddDeviceSheet {
  static void show(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final markaCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final seriNoCtrl = TextEditingController();
    final cihazAdiCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                    'Yeni Cihaz Stoğu Ekle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: markaCtrl,
                    decoration: const InputDecoration(labelText: 'Marka'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: modelCtrl,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: seriNoCtrl,
                    decoration: const InputDecoration(labelText: 'Seri No'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: cihazAdiCtrl,
                    decoration: const InputDecoration(labelText: 'Cihaz Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final device = Device(
                          id: 'DEV-${DateTime.now().millisecondsSinceEpoch}',
                          modelName: '${markaCtrl.text} ${modelCtrl.text}'.trim(),
                          serialNumber: seriNoCtrl.text,
                          customer: cihazAdiCtrl.text,
                          installDate: '',
                          warrantyStatus: '',
                          lastMaintenance: '',
                          warrantyEndDate: null,
                        );
                        Provider.of<DeviceProvider>(context, listen: false)
                            .addDevice(device);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Ekle'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}