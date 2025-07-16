import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:intl/intl.dart';

class ServiceHistoryDetailScreen extends StatelessWidget {
  final ServiceHistory serviceHistory;
  const ServiceHistoryDetailScreen({Key? key, required this.serviceHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşlem Tarihi: ${dateFormat.format(serviceHistory.date)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('İşlem Tipi: ${serviceHistory.type}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Açıklama: ${serviceHistory.description}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Teknisyen: ${serviceHistory.technician}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Durum: ', style: const TextStyle(fontSize: 16)),
                _StatusChip(status: serviceHistory.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get color {
    switch (status) {
      case 'Tamamlandı':
      case 'Başarılı':
        return Colors.green;
      case 'Beklemede':
        return Colors.orange;
      case 'Arızalı':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
} 