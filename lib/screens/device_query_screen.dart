import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'barcode_scanner_screen.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device.dart';

class CihazSorgulaScreen extends StatefulWidget {
  const CihazSorgulaScreen({Key? key}) : super(key: key);

  @override
  State<CihazSorgulaScreen> createState() => _CihazSorgulaScreenState();
}

class _CihazSorgulaScreenState extends State<CihazSorgulaScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Device? _selectedDevice;
  List<Device> _recentSearches = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  static const String _recentSearchesKey = 'recent_device_searches';
  
  // Yeni state değişkenleri
  String? _selectedModelName;
  List<Device> _devicesByModel = [];
  bool _showModelDetails = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    // Kalıcı verileri yükle
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Kalıcı verileri yükle
  Future<void> _loadRecentSearches() async {
    try {
      final box = await Hive.openBox('device_searches');
      final savedData = box.get(_recentSearchesKey, defaultValue: <Map>[]);
      
      if (savedData.isNotEmpty) {
        setState(() {
          _recentSearches = savedData.map<Device>((data) => Device.fromJson(Map<String, dynamic>.from(data))).toList();
        });
      }
    } catch (e) {
      // Hata durumunda boş liste ile devam et
      _recentSearches = [];
    }
  }

  // Kalıcı verileri kaydet
  Future<void> _saveRecentSearches() async {
    try {
      final box = await Hive.openBox('device_searches');
      final dataToSave = _recentSearches.map((device) => device.toJson()).toList();
      await box.put(_recentSearchesKey, dataToSave);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  void _addToRecentSearches(Device device) {
    if (!_recentSearches.contains(device)) {
      setState(() {
        _recentSearches.insert(0, device);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
      // Kalıcı olarak kaydet
      _saveRecentSearches();
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı'),
        backgroundColor: const Color(0xFF23408E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeviceDetails(Device device) {
    setState(() {
      _selectedDevice = device;
      _selectedModelName = null;
      _showModelDetails = false;
      _addToRecentSearches(device);
    });
    _fadeController.forward();
    _slideController.forward();
  }

  void _showModelDetailsView(String modelName) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final devicesByModel = deviceProvider.getDevicesByModelName(modelName);
    
    setState(() {
      _selectedModelName = modelName;
      _devicesByModel = devicesByModel;
      _selectedDevice = null;
      _showModelDetails = true;
    });
    _fadeController.forward();
    _slideController.forward();
  }

  // Son sorgulananları temizle
  void _clearRecentSearches() async {
    setState(() {
      _recentSearches.clear();
    });
    try {
      final box = await Hive.openBox('device_searches');
      await box.delete(_recentSearchesKey);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cihaz Sorgula',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modern Arama Kutusu
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Autocomplete<Device>(
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: GoogleFonts.montserrat(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Model, seri numarası veya müşteri...',
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF23408E),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF23408E), width: 2),
                      ),
                    ),
                  );
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Device>.empty();
                  }
                  final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
                  return deviceProvider.search(textEditingValue.text);
                },
                displayStringForOption: (Device device) => '${device.modelName} - ${device.serialNumber}',
                onSelected: _showDeviceDetails,
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final device = options.elementAt(index);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23408E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.devices_other_rounded,
                                  color: Color(0xFF23408E),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                device.modelName,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.serialNumber,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    device.customer,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => onSelected(device),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Kamerayla Tara Butonu
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF23408E),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    if (context.mounted) {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                      );
                      if (result != null && result.isNotEmpty) {
                        _searchController.text = result;
                        final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
                        final foundDevices = deviceProvider.search(result);
                        if (foundDevices.isNotEmpty) {
                          _showDeviceDetails(foundDevices.first);
                        }
                      }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Kamerayı kullanabilmek için izin vermelisiniz.'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(
                  'Kamerayla Tara',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Son Sorgulananlar
            if (_recentSearches.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Son Sorgulananlar',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearRecentSearches,
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: Text(
                      'Temizle',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    final device = _recentSearches[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _showDeviceDetails(device),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF23408E).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.devices_other_rounded,
                                      color: Color(0xFF23408E),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      device.modelName,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                device.serialNumber,
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: device.warrantyStatus == 'Devam Ediyor'
                                      ? const Color(0xFF43A047).withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  device.warrantyStatus,
                                  style: GoogleFonts.montserrat(
                                    color: device.warrantyStatus == 'Devam Ediyor'
                                        ? const Color(0xFF43A047)
                                        : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Model Detayları (Aynı model cihazlar için)
            if (_showModelDetails && _selectedModelName != null)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildModelDetailsCard(_selectedModelName!, _devicesByModel),
                ),
              ),

            // Seçilen Cihaz Detayları
            if (_selectedDevice != null)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: isTablet
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildDeviceCard(_selectedDevice!),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildDeviceDetails(_selectedDevice!),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildDeviceCard(_selectedDevice!),
                            const SizedBox(height: 16),
                            _buildDeviceDetails(_selectedDevice!),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelDetailsCard(String modelName, List<Device> devices) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final totalDevices = devices.length;
    final activeWarranty = devices.where((d) => d.warrantyStatus == 'Devam Ediyor').length;
    final expiredWarranty = totalDevices - activeWarranty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Başlığı ve İstatistikler
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF23408E).withOpacity(0.1),
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

          // İstatistik Kartları
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.1),
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
                    color: Colors.red.withOpacity(0.1),
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

          // Müşteri Listesi
          Text(
            'Satılan Müşteriler',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...devices.map((device) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: device.warrantyStatus == 'Devam Ediyor'
                      ? const Color(0xFF43A047).withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  device.warrantyStatus == 'Devam Ediyor'
                      ? Icons.verified_rounded
                      : Icons.warning_rounded,
                  color: device.warrantyStatus == 'Devam Ediyor'
                      ? const Color(0xFF43A047)
                      : Colors.red,
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
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: device.warrantyStatus == 'Devam Ediyor'
                      ? const Color(0xFF43A047).withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  device.warrantyStatus,
                  style: GoogleFonts.montserrat(
                    color: device.warrantyStatus == 'Devam Ediyor'
                        ? const Color(0xFF43A047)
                        : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () => _showDeviceDetails(device),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  color: const Color(0xFF23408E).withOpacity(0.1),
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
                      device.modelName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.serialNumber,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: device.warrantyStatus == 'Devam Ediyor'
                        ? const Color(0xFF43A047).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        device.warrantyStatus == 'Devam Ediyor'
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        color: device.warrantyStatus == 'Devam Ediyor'
                            ? const Color(0xFF43A047)
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        device.warrantyStatus,
                        style: GoogleFonts.montserrat(
                          color: device.warrantyStatus == 'Devam Ediyor'
                              ? const Color(0xFF43A047)
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDetails(Device device) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF23408E),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Cihaz Detayları',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            label: 'Seri Numarası',
            value: device.serialNumber,
            onCopy: () => _copyToClipboard(device.serialNumber, 'Seri numarası'),
          ),
          _DetailRow(
            label: 'Model Adı',
            value: device.modelName,
            onCopy: () => _copyToClipboard(device.modelName, 'Model adı'),
          ),
          _DetailRow(
            label: 'Müşteri/Kurum',
            value: device.customer,
            onCopy: () => _copyToClipboard(device.customer, 'Müşteri bilgisi'),
          ),
          _DetailRow(
            label: 'Kurulum Tarihi',
            value: device.installDate,
          ),
          _DetailRow(
            label: 'Son Bakım Tarihi',
            value: device.lastMaintenance,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23408E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Aynı model cihazları göster
                    _showModelDetailsView(device.modelName);
                  },
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: Text(
                    'Aynı Model',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Servis geçmişi gösterme özelliği eklenebilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Servis geçmişi özelliği yakında eklenecek'),
                        backgroundColor: Colors.orange.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: Text(
                    'Servis Geçmişi',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                color: Color(0xFF23408E),
                size: 20,
              ),
              tooltip: 'Kopyala',
            ),
        ],
      ),
    );
  }
} 