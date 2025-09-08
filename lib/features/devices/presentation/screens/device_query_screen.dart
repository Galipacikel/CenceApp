import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:async'; // removed unused import
import 'package:cence_app/features/devices/providers.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/widgets/common/cards/model_details_card.dart';
import 'package:cence_app/widgets/common/detail_row.dart';
import 'package:cence_app/features/scanner/presentation/screens/barcode_scanner_screen.dart';

class CihazSorgulaScreen extends ConsumerStatefulWidget {
  const CihazSorgulaScreen({super.key});

  @override
  ConsumerState<CihazSorgulaScreen> createState() => _CihazSorgulaScreenState();
}

class _CihazSorgulaScreenState extends ConsumerState<CihazSorgulaScreen>
    with TickerProviderStateMixin {
  TextEditingController? _searchController;
  Device? _selectedDevice;
   late AnimationController _fadeController;
   late AnimationController _slideController;
   late Animation<double> _fadeAnimation;
   late Animation<Offset> _slideAnimation;

   // Yeni state değişkenleri
   String? _selectedModelName;
   List<Device> _devicesByModel = [];
   bool _showModelDetails = false;

   // Forms arama için
   // late FormsRepositoryV2 _formsRepository;
  // yerel arama sonuçları ve loading state’i kaldırıldı; Notifier kullanılacak

   // int _autocompleteKeyCounter = 0; // removed unused

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

    // Kalıcı son sorguları Notifier üzerinden yükle
    ref.read(deviceQueryNotifierProvider.notifier).init();

    // DI: Forms repository'yi al (V2)
    // _formsRepository = Provider.of<FormsRepositoryV2>(context, listen: false);

    // Arama kutusu listener'ı fieldViewBuilder içinde controller sağlandığında eklenecek
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    // Autocomplete kendi controller'ını yönetir; sadece listener'ı kaldırıyoruz
    _searchController?.removeListener(_onSearchTextChanged);
    // _searchController?.dispose(); // KALDIRILDI: RawAutocomplete yönetiyor
    super.dispose();
  }

  void _onSearchTextChanged() {
    final q = _searchController?.text.trim() ?? '';
    ref.read(deviceQueryNotifierProvider.notifier).onQueryChanged(q);
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
    });
    ref.read(deviceQueryNotifierProvider.notifier).addToRecents(device);
    _fadeController.forward();
    _slideController.forward();
  }

  void _showModelDetailsView(String modelName) {
    final asyncDevices = ref.read(devicesListProvider);
    final devices = asyncDevices.maybeWhen(
      data: (d) => d,
      orElse: () => const <Device>[],
    );
    final devicesByModel = devices
        .where((d) => d.modelName.toLowerCase() == modelName.toLowerCase())
        .toList();

    setState(() {
      _selectedModelName = modelName;
      _devicesByModel = devicesByModel;
      _selectedDevice = null;
      _showModelDetails = true;
    });
    _fadeController.forward();
    _slideController.forward();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cihaz Sorgula',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              // Web platformunda permission kontrolü
              if (kIsWeb) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Kamera izni web platformunda otomatik olarak verilir'),
                  ),
                );
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
                return;
              }
              
              final status = await Permission.camera.request();
              if (!context.mounted) return;
              if (status.isGranted) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Kamera izni gerekli'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cihaz arama konusunda yardım için destek ekibimizle iletişime geçin.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
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
                    color: const Color(0xFF23408E).withAlpha(26),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Autocomplete<Device>(
                // key: ValueKey('forms-ac-$_autocompleteKeyCounter'), // KALDIRILDI: input'u sıfırlıyordu
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // Autocomplete her yeniden oluşturulduğunda controller değişebiliyor.
                      // Bu nedenle referansı ve listener’ı daima senkron tutuyoruz.
                      if (_searchController != textEditingController) {
                        _searchController?.removeListener(_onSearchTextChanged);
                        _searchController = textEditingController;
                        _searchController?.addListener(_onSearchTextChanged);
                      }
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        style: GoogleFonts.montserrat(fontSize: 16),
                        decoration: InputDecoration(
                          hintText:
                              'Model veya seri numarası ile ara... (en az 2 karakter)',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF23408E).withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF23408E),
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF23408E),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                // Overlay yerine altta liste göstereceğiz; Autocomplete seçeneklerini boş bırakıyoruz
                optionsBuilder: (TextEditingValue textEditingValue) =>
                    const Iterable<Device>.empty(),
                displayStringForOption: (Device device) =>
                    '${device.modelName} - ${device.serialNumber}',
                onSelected: _showDeviceDetails,
                optionsViewBuilder: (context, onSelected, options) {
                  // Overlay kullanılmıyor
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 8),
            // Yükleniyor / Sonuçlar Paneli
            Builder(
              builder: (context) {
                final q = _searchController?.text.trim() ?? '';
                final dqState = ref.watch(deviceQueryNotifierProvider);
                if (dqState.isLoading && q.length >= 2) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Yükleniyor... Lütfen bekleyin',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (q.length >= 2) {
                  if (dqState.searchResults.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      child: Text(
                        'Sonuç bulunamadı',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: dqState.searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final device = dqState.searchResults[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF23408E).withAlpha(26),
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
                              if (device.customer.isNotEmpty)
                                Text(
                                  device.customer,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () => _showDeviceDetails(device),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

            // Kamerayla Tara Butonu
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
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
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  
                  // Web platformunda permission kontrolü
                  if (kIsWeb) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Kamera izni web platformunda otomatik olarak verilir'),
                      ),
                    );
                    final code = await navigator.push<String>(
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerScreen(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (code != null && code.isNotEmpty) {
                       _searchController?.text = code;
                     }
                    return;
                  }
                  
                  final status = await Permission.camera.request();
                  if (!context.mounted) return;
                  if (status.isGranted) {
                    final code = await navigator.push<String>(
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerScreen(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (code != null && code.isNotEmpty) {
                      _searchController?.text = code;
                      try {
                        final foundDevices = await ref
                            .read(deviceQueryNotifierProvider.notifier)
                            .searchOnce(code);
                        if (!context.mounted) return;
                        if (foundDevices.isNotEmpty) {
                          _showDeviceDetails(foundDevices.first);
                        }
                      } catch (_) {}
                    }
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Kamerayı kullanabilmek için izin vermelisiniz.',
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
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

            // Bilgi kartları
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
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
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bilgi',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cihaz aramak için model adı veya seri numarasını yazmaya başlayın. Son sorgulanan cihazlar aşağıda listelenir.',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Son Sorgulananlar
            Builder(
              builder: (context) {
                final recent = ref.watch(deviceQueryNotifierProvider).recent;
                if (recent.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
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
                    onPressed: () => ref
                        .read(deviceQueryNotifierProvider.notifier)
                        .clearRecents(),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: isTablet ? 140 : 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final device = recent[index];
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
                                color: Colors.black.withAlpha(20),
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
                                      color: const Color(
                                        0xFF23408E,
                                      ).withAlpha(26),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: device.warrantyEndDate != null
                                      ? (device.calculatedWarrantyStatus ==
                                                'Devam Ediyor'
                                            ? const Color(
                                                0xFF43A047,
                                              ).withAlpha(26)
                                            : Colors.red.withAlpha(26))
                                      : Colors.grey.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  device.warrantyEndDate != null
                                      ? device.calculatedWarrantyStatus
                                      : 'Henüz belirlenmemiş',
                                  style: GoogleFonts.montserrat(
                                    color: device.warrantyEndDate != null
                                        ? (device.calculatedWarrantyStatus ==
                                                  'Devam Ediyor'
                                              ? const Color(0xFF43A047)
                                              : Colors.red)
                                        : Colors.grey,
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
           );
         },
      ),

          // Detay bölümleri
          if (_selectedDevice != null) ...[
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDeviceCard(_selectedDevice!),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDeviceDetails(_selectedDevice!),
              ),
            ),
          ],
          if (_showModelDetails && _selectedModelName != null) ...[
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ModelDetailsCard(
                  modelName: _selectedModelName!,
                  devices: _devicesByModel,
                  onDeviceTap: _showDeviceDetails,
                ),
              ),
            ),
          ],

          ],
        ),
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
            color: Colors.black.withAlpha(26),
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
                  color: const Color(0xFF23408E).withAlpha(26),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: device.warrantyEndDate != null
                        ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                              ? const Color(0xFF43A047).withAlpha(26)
                              : Colors.red.withAlpha(26))
                        : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        device.warrantyEndDate != null
                            ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                                  ? Icons.verified_rounded
                                  : Icons.warning_rounded)
                            : Icons.help_outline_rounded,
                        color: device.warrantyEndDate != null
                            ? (device.calculatedWarrantyStatus == 'Devam Ediyor'
                                  ? const Color(0xFF43A047)
                                  : Colors.red)
                            : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        device.calculatedWarrantyStatus,
                        style: GoogleFonts.montserrat(
                          color: device.warrantyEndDate != null
                              ? (device.calculatedWarrantyStatus ==
                                        'Devam Ediyor'
                                    ? const Color(0xFF43A047)
                                    : Colors.red)
                              : Colors.grey,
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
            color: Colors.black.withAlpha(26),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF23408E).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF23408E).withAlpha(51)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23408E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cihaz Detayları',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF23408E),
                        ),
                      ),
                      Text(
                        device.modelName,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23408E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    device.serialNumber,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DetailRow(
            label: 'Seri Numarası',
            value: device.serialNumber,
            onCopy: () =>
                _copyToClipboard(device.serialNumber, 'Seri numarası'),
          ),
          DetailRow(
            label: 'Model Adı',
            value: device.modelName,
            onCopy: () => _copyToClipboard(device.modelName, 'Model adı'),
          ),
          DetailRow(
            label: 'Müşteri/Kurum',
            value: device.customer,
            onCopy: device.customer.isNotEmpty
                ? () => _copyToClipboard(device.customer, 'Müşteri bilgisi')
                : null,
          ),
          DetailRow(label: 'Kurulum Tarihi', value: device.installDate),
          DetailRow(label: 'Son Bakım Tarihi', value: device.lastMaintenance),
          DetailRow(
            label: 'Garanti Bitiş Tarihi',
            value: device.warrantyEndDateString,
          ),
          if (device.warrantyEndDate != null) ...[
            if (device.daysUntilWarrantyExpiry > 0) ...[
              DetailRow(
                label: 'Garantiye Kalan Süre',
                value: '${device.daysUntilWarrantyExpiry} gün',
              ),
            ] else if (device.daysUntilWarrantyExpiry == 0) ...[
              DetailRow(label: 'Garanti Durumu', value: 'Bugün sona eriyor!'),
            ] else if (device.daysUntilWarrantyExpiry < 0) ...[
              DetailRow(
                label: 'Garanti Durumu',
                value: '${device.daysUntilWarrantyExpiry.abs()} gün önce bitti',
              ),
            ],
          ] else ...[
            DetailRow(label: 'Garanti Durumu', value: 'Henüz belirlenmemiş'),
          ],
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
                        content: const Text(
                          'Servis geçmişi özelliği yakında eklenecek',
                        ),
                        backgroundColor: Colors.orange.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
