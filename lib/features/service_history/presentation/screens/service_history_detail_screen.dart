import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/devices/providers.dart';
import 'package:intl/intl.dart';

class ServiceHistoryDetailScreen extends ConsumerWidget {
  final ServiceHistory serviceHistory;
  const ServiceHistoryDetailScreen({super.key, required this.serviceHistory});

  void _showFullScreenPhoto(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Photo with InteractiveViewer
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 300,
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Kurulum':
        return Colors.green.shade800;
      case 'Başarılı':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color getStatusTextColor(String status) {
    return Colors.white;
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'Kurulum':
        return 'Kurulum';
      case 'Başarılı':
        return 'Başarılı';
      default:
        return status;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Kurulum':
        return Icons.check_circle_rounded;
      case 'Başarılı':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final isWide = MediaQuery.of(context).size.width > 600;
    final devicesAsync = ref.watch(devicesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 90 : 70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23408E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + (isWide ? 10 : 6),
            left: isWide ? 32 : 18,
            right: isWide ? 32 : 18,
            bottom: isWide ? 12 : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'İşlem Detayı',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 22 : 20,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Paylaşım özelliği yakında eklenecek'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF23408E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                tooltip: 'Paylaş',
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ana bilgi kartı
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve durum
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          serviceHistory.serialNumber,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(serviceHistory.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon(serviceHistory.status),
                              color: getStatusTextColor(serviceHistory.status),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              getStatusLabel(serviceHistory.status),
                              style: TextStyle(
                                color: getStatusTextColor(
                                  serviceHistory.status,
                                ),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fotoğraflar
                  if (serviceHistory.photos != null && serviceHistory.photos!.isNotEmpty) ...[                    
                    const Text(
                      'Fotoğraflar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: serviceHistory.photos!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenPhoto(context, serviceHistory.photos![index]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  serviceHistory.photos![index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.error_outline,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tarih (sadece Oluşturma)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: const Color(0xFF23408E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Oluşturma: ' + dateFormat.format(serviceHistory.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23408E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  devicesAsync.when(
                    data: (devices) {
                      final device = devices.firstWhere(
                        (d) => d.serialNumber == serviceHistory.serialNumber,
                        orElse: () => Device(
                          id: '',
                          serialNumber: serviceHistory.serialNumber,
                          modelName: 'Bilinmeyen Cihaz',
                          customer: '',
                          installDate: '',
                          warrantyStatus: '',
                          lastMaintenance: '',
                          warrantyEndDate: DateTime.now(),
                          stockQuantity: 0,
                        ),
                      );
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cihaz Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: serviceHistory.status == 'Kurulum' ? Icons.build_circle : Icons.devices_other,
                                  label: serviceHistory.status == 'Kurulum' ? 'Kurulan Cihaz' : 'Cihaz Adı',
                                  value: serviceHistory.deviceName.isNotEmpty
                                      ? serviceHistory.deviceName
                                      : (device.modelName.isNotEmpty ? device.modelName : 'Belirtilmemiş'),
                                  color: serviceHistory.status == 'Kurulum' ? Colors.green.shade700 : const Color(0xFF23408E),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.qr_code,
                                  label: 'Seri Numarası',
                                  value: serviceHistory.serialNumber,
                                  color: const Color(0xFF23408E),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.business,
                                  label: 'Firma',
                                  value: serviceHistory.musteri.isNotEmpty
                                      ? serviceHistory.musteri
                                      : (device.customer.isNotEmpty ? device.customer : 'Belirtilmemiş'),
                                  color: const Color(0xFF23408E),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.memory,
                                  label: 'Marka',
                                  value: serviceHistory.brand.isNotEmpty ? serviceHistory.brand : 'Belirtilmemiş',
                                  color: const Color(0xFF23408E),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.category,
                                  label: 'Model',
                                  value: serviceHistory.model.isNotEmpty ? serviceHistory.model : 'Belirtilmemiş',
                                  color: const Color(0xFF23408E),
                                ),
                                const SizedBox(height: 12),
                                if (serviceHistory.status == 'Kurulum') ...[
                                  _buildInfoRow(
                                    icon: Icons.event_available,
                                    label: 'Kurulum Tarihi',
                                    value: dateFormat.format(serviceHistory.date),
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                  if (serviceHistory.location.isNotEmpty) ...[
                                    _buildInfoRow(
                                      icon: Icons.location_on,
                                      label: 'Kurulum Lokasyonu',
                                      value: serviceHistory.location,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                                if (serviceHistory.serviceStart != null) ...[
                                  _buildInfoRow(
                                    icon: Icons.play_circle_outline,
                                    label: 'Servis Başlangıç',
                                    value: dateFormat.format(serviceHistory.serviceStart!),
                                    color: const Color(0xFF23408E),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (serviceHistory.serviceEnd != null) ...[
                                  _buildInfoRow(
                                    icon: Icons.stop_circle_outlined,
                                    label: 'Servis Bitiş',
                                    value: dateFormat.format(serviceHistory.serviceEnd!),
                                    color: const Color(0xFF23408E),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                // Garanti bilgisini detaylı göster
                                Builder(
                                  builder: (_) {
                                    String text;
                                    Color color;
                                    final end = device.warrantyEndDate;
                                    if (end != null) {
                                      final endStr = dateFormat.format(end);
                                      if (DateTime.now().isBefore(end)) {
                                        text = 'Garanti: $endStr tarihine kadar devam ediyor';
                                        color = const Color(0xFF43A047);
                                      } else {
                                        text = 'Garanti: $endStr tarihinde bitti';
                                        color = const Color(0xFFE53935);
                                      }
                                    } else {
                                      text = 'Garanti bilgisi belirtilmemiş';
                                      color = const Color(0xFF23408E);
                                    }
                                    return _buildInfoRow(
                                      icon: Icons.verified,
                                      label: 'Garanti',
                                      value: text,
                                      color: color,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.location_on,
                                  label: 'Lokasyon',
                                  value: serviceHistory.location.isNotEmpty ? serviceHistory.location : 'Belirtilmemiş',
                                  color: const Color(0xFF23408E),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Teknisyen',
                    value: serviceHistory.technician,
                    color: const Color(0xFF23408E),
                  ),
                  const SizedBox(height: 20),

                  if (serviceHistory.description.isNotEmpty) ...[
                    const Text(
                      'Açıklama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        serviceHistory.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (serviceHistory.kullanilanParcalar.isNotEmpty) ...[
                    const Text(
                      'Kullanılan Parçalar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...serviceHistory.kullanilanParcalar.map(
                      (part) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF23408E).withAlpha(51),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23408E).withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.memory,
                                size: 16,
                                color: Color(0xFF23408E),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    part.parcaAdi,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF1C1C1C),
                                    ),
                                  ),
                                  Text(
                                    'Kod: ${part.parcaKodu}',
                                    style: TextStyle(
                                      fontSize: 12,
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
                                color: const Color(0xFF23408E).withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${part.stokAdedi} adet',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF23408E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),

            if (serviceHistory.photos != null &&
                serviceHistory.photos!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fotoğraflar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: serviceHistory.photos!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenPhoto(context, serviceHistory.photos![index]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      serviceHistory.photos![index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(100),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
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
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
