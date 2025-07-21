import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:intl/intl.dart';

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
        title: const Text('İşlem Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşlem Tarihi: ${dateFormat.format(serviceHistory.date)}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('İşlem Tipi: ${serviceHistory.cihazId}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('Açıklama: ${serviceHistory.description}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
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