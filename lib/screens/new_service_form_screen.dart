import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/stock_part.dart';
import '../models/device.dart';

class NewServiceFormScreen extends StatefulWidget {
  final StockPartRepository? stockRepository;
  final DeviceRepository? deviceRepository;
  const NewServiceFormScreen({Key? key, this.stockRepository, this.deviceRepository}) : super(key: key);

  @override
  State<NewServiceFormScreen> createState() => _NewServiceFormScreenState();
}

class SelectedPart {
  final StockPart part;
  int adet;
  SelectedPart({required this.part, this.adet = 1});
}

class _NewServiceFormScreenState extends State<NewServiceFormScreen> {
  int _formTipi = 0; // 0: Kurulum, 1: Bakım, 2: Arıza
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  DateTime? _date;
  late TextEditingController _dateController;
  File? _pickedImage;
  
  // Parça seçimi için yeni alanlar
  StockPart? _selectedPart;
  bool _noPartInstalled = false;
  final TextEditingController _partSearchController = TextEditingController();
  List<StockPart> _allParts = [];
  List<StockPart> _filteredParts = [];
  bool _showPartSuggestions = false;
  final StockPartRepository _stockRepository = MockStockRepository();
  
  // Cihaz seçimi için
  Device? _selectedDevice;
  final TextEditingController _deviceSearchController = TextEditingController();
  List<Device> _allDevices = [];
  List<Device> _filteredDevices = [];
  bool _showDeviceSuggestions = false;
  final DeviceRepository _deviceRepository = MockDeviceRepository();
  
  // Kategori seçimi için
  String? _selectedCategory;
  final List<String> _categories = ['Tüm Parçalar', 'Elektronik', 'Mekanik', 'Sarf Malzeme', 'Diğer'];
  final Map<String, IconData> _categoryIcons = {
    'Tüm Parçalar': Icons.all_inclusive,
    'Elektronik': Icons.memory,
    'Mekanik': Icons.settings,
    'Sarf Malzeme': Icons.cable,
    'Diğer': Icons.category,
  };
  final Map<String, Color> _categoryColors = {
    'Tüm Parçalar': const Color(0xFF23408E),
    'Elektronik': const Color(0xFF23408E),
    'Mekanik': const Color(0xFF00BFAE),
    'Sarf Malzeme': const Color(0xFFFF7043),
    'Diğer': const Color(0xFFB0B6C3),
  };

  List<SelectedPart> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _loadParts();
    _loadDevices();
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _technicianController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _partSearchController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _loadParts() async {
    final parts = await _stockRepository.getAll();
    setState(() {
      _allParts = parts;
      _filteredParts = parts;
    });
  }

  Future<void> _loadDevices() async {
    final devices = await _deviceRepository.getAll();
    setState(() {
      _allDevices = devices;
      _filteredDevices = devices;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedPart = null;
      _partSearchController.clear();
      _showPartSuggestions = false;
      
      _filteredParts = _allParts;
      _filteredParts.sort((a, b) {
        return a.parcaAdi.compareTo(b.parcaAdi);
      });
    });
  }

  void _filterParts(String query) {
    setState(() {
      List<StockPart> baseParts = _allParts;
      
      if (query.isEmpty) {
        _filteredParts = baseParts;
      } else {
        _filteredParts = baseParts.where((part) =>
          part.parcaAdi.toLowerCase().contains(query.toLowerCase()) ||
          part.parcaKodu.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      _filteredParts.sort((a, b) {
        return a.parcaAdi.compareTo(b.parcaAdi);
      });
    });
  }

  void _filterDevices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDevices = _allDevices;
      } else {
        _filteredDevices = _allDevices.where((device) =>
          device.modelName.toLowerCase().contains(query.toLowerCase()) ||
          device.serialNumber.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      _showDeviceSuggestions = true;
    });
  }

  void _selectPart(StockPart part) {
    setState(() {
      _selectedPart = part;
      _partSearchController.text = '${part.parcaAdi} (${part.parcaKodu})';
      _showPartSuggestions = false;
      _noPartInstalled = false;
    });
  }

  void _selectDevice(Device device) {
    setState(() {
      _selectedDevice = device;
      _deviceSearchController.text = '${device.modelName} (${device.serialNumber})';
      _showDeviceSuggestions = false;
    });
  }

  void _updateDateController() {
    _dateController.text = _date == null ? '' : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}';
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF23408E)),
              title: const Text('Kamera ile Çek'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF23408E)),
              title: const Text('Galeriden Seç'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    }
  }

  void _addOrUpdateSelectedPart(StockPart part, int adet) {
    setState(() {
      final idx = _selectedParts.indexWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
      if (idx >= 0) {
        _selectedParts[idx].adet = adet;
      } else {
        _selectedParts.add(SelectedPart(part: part, adet: adet));
      }
    });
  }

  void _removeSelectedPart(StockPart part) {
    setState(() {
      _selectedParts.removeWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
    });
  }

  void _onKaydet() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a device.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_customerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer/company name.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_technicianController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter technician name.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    // Parça seçimi kontrolü
    if (_selectedParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one part and quantity.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    // Stoktan düşme işlemi
    for (final sp in _selectedParts) {
      await _stockRepository.decreaseQuantity(sp.part.parcaKodu, sp.adet);
    }
    Navigator.pop(context, {
      'formTipi': _formTipi,
      'deviceId': _selectedDevice!.id,
      'customer': _customerController.text,
      'technician': _technicianController.text,
      'description': _descriptionController.text,
      'date': _date,
      'usedParts': _selectedParts.map((sp) => {'partCode': sp.part.parcaKodu, 'partName': sp.part.parcaAdi, 'quantity': sp.adet}).toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record successfully added!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );
  }

  Color _getStockStatusColor(StockPart part) {
    if (part.stokAdedi <= 5) {
      return const Color(0xFFFFC107); // Sarı - Düşük
    } else {
      return const Color(0xFF43A047); // Yeşil - Normal
    }
  }

  String _getStockStatusText(StockPart part) {
    if (part.stokAdedi <= 5) {
      return 'Düşük';
    } else {
      return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateDateController();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Service Form',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Form Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _FormTypeChip(
                  label: 'Installation',
                  selected: _formTipi == 0,
                  color: const Color(0xFF23408E),
                  onTap: () => setState(() => _formTipi = 0),
                ),
                const SizedBox(width: 8),
                _FormTypeChip(
                  label: 'Maintenance',
                  selected: _formTipi == 1,
                  color: const Color(0xFFFFC107),
                  onTap: () => setState(() => _formTipi = 1),
                ),
                const SizedBox(width: 8),
                _FormTypeChip(
                  label: 'Fault',
                  selected: _formTipi == 2,
                  color: const Color(0xFFE53935),
                  onTap: () => setState(() => _formTipi = 2),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // Device Information
            const Text('Device Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            const Text('Device', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Responsive device selection
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            TextField(
                      controller: _deviceSearchController,
                      readOnly: false,
              decoration: InputDecoration(
                        hintText: 'Model, serial number or customer...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                        suffixIcon: _selectedDevice != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedDevice = null;
                                    _deviceSearchController.clear();
                                    _showDeviceSuggestions = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterDevices,
                      onTap: () {
                        setState(() {
                          _showDeviceSuggestions = true;
                        });
                      },
                    ),
                    if (_showDeviceSuggestions && _filteredDevices.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight > 300 ? 300 : constraints.maxHeight * 0.5,
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
                          itemCount: _filteredDevices.length,
                          itemBuilder: (context, index) {
                            final device = _filteredDevices[index];
                            return ListTile(
                              title: Text('${device.modelName} (${device.serialNumber})'),
                              onTap: () => _selectDevice(device),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            const Text('Customer/Company Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _customerController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Enter customer or company name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Photo upload area
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23408E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  label: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            // Form Details
            const Text('Form Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            // Installation Date header
            const Text('Installation Date', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              readOnly: true,
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'dd.mm.yyyy',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Technician header
            const Text('Technician', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _technicianController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Enter technician name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Used Parts header
            const Text('Used Parts', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Part search box
            TextField(
              controller: _partSearchController,
              decoration: InputDecoration(
                hintText: 'Search by part name or code...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF23408E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _partSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF23408E)),
                        onPressed: () {
                          setState(() {
                            _partSearchController.clear();
                            _filterParts('');
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) => _filterParts(val),
            ),
            const SizedBox(height: 8),
            // Modern multi-part selection based on cards
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: _filteredParts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: Text('No part found matching your search', style: TextStyle(color: Colors.grey))),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _filteredParts.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                final part = _filteredParts[index];
                                final selected = _selectedParts.firstWhere(
                                  (sp) => sp.part.parcaKodu == part.parcaKodu,
                                  orElse: () => SelectedPart(part: part, adet: 0),
                                );
                                final isSelected = selected.adet > 0;
                                final isOutOfStock = part.stokAdedi == 0;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  padding: const EdgeInsets.all(12),
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
                                          color: const Color(0xFF43A047).withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: isOutOfStock
                                            ? null
                                            : () {
                                                if (isSelected) {
                                                  _removeSelectedPart(part);
                                                } else {
                                                  _addOrUpdateSelectedPart(part, 1);
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
                                                Text(part.parcaAdi, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isOutOfStock ? Colors.grey : Colors.black)),
                                                if (isOutOfStock)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text('Out of Stock', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('Code: ${part.parcaKodu}', style: const TextStyle(fontSize: 12, color: Color(0xFF23408E))),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('Stock: ${part.stokAdedi}', style: const TextStyle(fontSize: 12, color: Color(0xFF23408E))),
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
                                              icon: const Icon(Icons.remove_circle_outline, size: 24, color: Color(0xFF23408E)),
                                              splashRadius: 20,
                                              onPressed: selected.adet > 1
                                                  ? () => _addOrUpdateSelectedPart(part, selected.adet - 1)
                                                  : null,
                                            ),
                                            Text('${selected.adet}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 24, color: Color(0xFF23408E)),
                                              splashRadius: 20,
                                              onPressed: part.stokAdedi > selected.adet
                                                  ? () => _addOrUpdateSelectedPart(part, selected.adet + 1)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_selectedParts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 2),
                        child: Wrap(
                          spacing: 8,
                          children: _selectedParts.map((sp) => Chip(
                            label: Text('${sp.part.parcaAdi} x${sp.adet}'),
                            backgroundColor: const Color(0xFFE3F6ED),
                            labelStyle: const TextStyle(color: Color(0xFF23408E), fontWeight: FontWeight.w600),
                            deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFF23408E)),
                            onDeleted: () => _removeSelectedPart(sp.part),
                          )).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Description header
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write down the work done and your notes here...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23408E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _onKaydet,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _FormTypeChip({required this.label, required this.selected, required this.onTap, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 