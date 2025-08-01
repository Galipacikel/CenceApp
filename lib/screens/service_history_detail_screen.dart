import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ServiceHistoryDetailScreen extends StatelessWidget {
  final ServiceHistory serviceHistory;
  const ServiceHistoryDetailScreen({Key? key, required this.serviceHistory}) : super(key: key);

  Map<String, dynamic> getStatusData(String status) {
    switch (status) {
      case 'Başarılı':
        return {
          'label': 'Başarılı',
          'color': Colors.blue.shade800,
          'bgColor': Colors.blue.shade100,
          'icon': Icons.check_circle_rounded,
        };
      case 'Beklemede':
        return {
          'label': 'Beklemede',
          'color': Colors.amber.shade800,
          'bgColor': Colors.amber.shade200,
          'icon': Icons.hourglass_bottom_rounded,
        };
      case 'Arızalı':
        return {
          'label': 'Arızalı',
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade100,
          'icon': Icons.error_rounded,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey.shade800,
          'bgColor': Colors.grey.shade200,
          'icon': Icons.info_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final statusData = getStatusData(serviceHistory.status);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'İşlem Detayı',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paylaşım özelliği yakında eklenecek'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İşlem detayları konusunda yardım için destek ekibimizle iletişime geçin.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşlem Tarihi: ${dateFormat.format(serviceHistory.date)}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('İşlem Tipi: ${serviceHistory.deviceId}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('Müşteri/Kurum: ${serviceHistory.musteri}', style: const TextStyle(fontSize: 16, color: Color(0xFF23408E), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Açıklama: ${serviceHistory.description}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            
            // Fotoğraflar bölümü
            if (serviceHistory.photos != null && serviceHistory.photos!.isNotEmpty) ...[
              const Text('Fotoğraflar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: serviceHistory.photos!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(serviceHistory.photos![index]),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (serviceHistory.kullanilanParcalar.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kullanılan Parçalar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: serviceHistory.kullanilanParcalar.map((p) => Chip(
                      label: Text('${p.parcaAdi} x${p.stokAdedi}', style: const TextStyle(fontSize: 13)),
                      backgroundColor: Colors.grey.shade100,
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            Text('Teknisyen: ${serviceHistory.technician}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Durum: ', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusData['bgColor'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusData['icon'], color: statusData['color'], size: 20),
                      const SizedBox(width: 6),
                      Text(statusData['label'], style: TextStyle(color: statusData['color'], fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 