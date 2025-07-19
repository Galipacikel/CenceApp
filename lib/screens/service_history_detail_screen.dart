import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:intl/intl.dart';

class ServiceHistoryDetailScreen extends StatelessWidget {
  final ServiceHistory serviceHistory;
  const ServiceHistoryDetailScreen({Key? key, required this.serviceHistory}) : super(key: key);

  String getStatusLabel(String status) {
    switch (status) {
      case 'Başarılı':
        return 'Başarılı';
      case 'Beklemede':
        return 'Beklemede';
      case 'Arızalı':
        return 'Arızalı';
      default:
        return status;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Başarılı':
        return const Color(0xFF43A047); // Yeşil
      case 'Beklemede':
        return const Color(0xFFFFC107); // Modern sarı
      case 'Arızalı':
        return const Color(0xFFE53935); // Kırmızı
      default:
        return const Color(0xFF43A047);
    }
  }

  Color getStatusTextColor(String status) {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final statusLabel = getStatusLabel(serviceHistory.status);
    final statusBgColor = getStatusBgColor(serviceHistory.status);
    final statusTextColor = getStatusTextColor(serviceHistory.status);
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
            Text('İşlem Tipi: ${serviceHistory.type}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('Açıklama: ${serviceHistory.description}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 8),
            Text('Teknisyen: ${serviceHistory.technician}', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Durum: ', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1C))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 