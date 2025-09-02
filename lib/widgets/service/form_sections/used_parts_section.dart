import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock_tracking/presentation/providers/filtered_parts_provider.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';

class UsedPartsSection extends ConsumerStatefulWidget {
  const UsedPartsSection({super.key});

  @override
  ConsumerState<UsedPartsSection> createState() => _UsedPartsSectionState();
}

class _UsedPartsSectionState extends ConsumerState<UsedPartsSection> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _otherQtyController = TextEditingController();
  bool _showOtherPartInput = false;

  @override
  void dispose() {
    _searchController.dispose();
    _otherNameController.dispose();
    _otherQtyController.dispose();
    super.dispose();
  }

  void _addCustomPart() {
    if (_otherNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parça adı boş olamaz.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int quantity = 1;
    if (_otherQtyController.text.isNotEmpty) {
      quantity = int.tryParse(_otherQtyController.text) ?? 1;
      if (quantity <= 0) quantity = 1;
    }

    final customPart = StockPart(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      parcaAdi: _otherNameController.text.trim(),
      parcaKodu: 'ÖZEL',
      stokAdedi: quantity,
      criticalLevel: 0,
    );

    try {
      ref.read(newServiceFormProvider.notifier).addOrUpdatePart(customPart, quantity);
    } catch (_) {}

    setState(() {
      _otherNameController.clear();
      _otherQtyController.clear();
      _showOtherPartInput = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customPart.parcaAdi} eklendi.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partsAsync = ref.watch(filteredPartsProvider);
    final selectedParts = ref.watch(newServiceFormProvider).activeTabData.selectedParts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Parça adı veya kodu ile ara...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF23408E)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF23408E)),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                      ref.read(inventoryProvider.notifier).setPartSearch('');
                    },
                  )
                : null,
          ),
          onChanged: (val) => ref.read(inventoryProvider.notifier).setPartSearch(val),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showOtherPartInput = !_showOtherPartInput;
                    if (!_showOtherPartInput) {
                      _otherNameController.clear();
                      _otherQtyController.clear();
                    }
                  });
                },
                icon: Icon(
                  _showOtherPartInput ? Icons.remove : Icons.add,
                  color: const Color(0xFF23408E),
                ),
                label: const Text(
                  'Diğer Parça Ekle',
                  style: TextStyle(color: Color(0xFF23408E)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF23408E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showOtherPartInput) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Özel Parça Ekle',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF23408E),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otherNameController,
                  decoration: InputDecoration(
                    hintText: 'Parça adını girin...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otherQtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Miktar (varsayılan: 1)',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addCustomPart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23408E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ekle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            minHeight: 200,
          ),
          child: partsAsync.when(
            data: (parts) {
              if (parts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aramanıza uygun parça bulunamadı',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: parts.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final part = parts[index];
                  final selected = selectedParts.firstWhere(
                    (sp) => sp.part.parcaKodu == part.parcaKodu,
                    orElse: () => SelectedPart(part: part, adet: 0),
                  );
                  final isSelected = selected.adet > 0;
                  final isOutOfStock = part.stokAdedi == 0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.grey.shade100
                          : isSelected
                              ? const Color(0xFFE3F6ED)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF43A047)
                            : isOutOfStock
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF43A047).withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: isOutOfStock
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${part.parcaAdi} stokta bulunmuyor.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              : () {
                                  final notifier = ref.read(newServiceFormProvider.notifier);
                                  if (isSelected) {
                                    notifier.removePart(part);
                                  } else {
                                    notifier.addOrUpdatePart(part, 1);
                                  }
                                },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF43A047) : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: isSelected ? const Color(0xFF43A047) : Colors.white,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      part.parcaAdi,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: MediaQuery.of(context).size.width < 400 ? 13 : 15,
                                        color: isOutOfStock ? Colors.grey : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  if (isOutOfStock)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Stokta Yok',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  else if (part.stokAdedi <= part.criticalLevel)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Kritik Seviye',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Kod: ${part.parcaKodu}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF23408E)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: part.stokAdedi == 0
                                          ? Colors.red.shade100
                                          : part.stokAdedi <= part.criticalLevel
                                              ? Colors.orange.shade100
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Stok: ${part.stokAdedi}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: part.stokAdedi == 0
                                            ? Colors.red
                                            : part.stokAdedi <= part.criticalLevel
                                                ? Colors.orange
                                                : const Color(0xFF23408E),
                                        fontWeight: part.stokAdedi == 0 || part.stokAdedi <= part.criticalLevel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isOutOfStock && isSelected)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 24,
                                  color: Color(0xFF23408E),
                                ),
                                splashRadius: 20,
                                onPressed: selected.adet > 1
                                    ? () {
                                        final notifier = ref.read(newServiceFormProvider.notifier);
                                        notifier.addOrUpdatePart(part, selected.adet - 1);
                                      }
                                    : null,
                              ),
                              Text(
                                '${selected.adet}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF23408E),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 24,
                                  color: Color(0xFF23408E),
                                ),
                                splashRadius: 20,
                                onPressed: part.stokAdedi > selected.adet
                                    ? () {
                                        final notifier = ref.read(newServiceFormProvider.notifier);
                                        notifier.addOrUpdatePart(part, selected.adet + 1);
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Stokta sadece ${part.stokAdedi} adet ${part.parcaAdi} bulunuyor.'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Parçalar yüklenirken hata oluştu: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        if (selectedParts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 2),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedParts
                  .map(
                    (sp) => ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Chip(
                        label: Flexible(
                          child: Text(
                            '${sp.part.parcaAdi} x${sp.adet}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE3F6ED),
                        labelStyle: const TextStyle(
                          color: Color(0xFF23408E),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF23408E),
                        ),
                        onDeleted: () => ref.read(newServiceFormProvider.notifier).removePart(sp.part),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}