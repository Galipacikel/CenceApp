import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_history.dart';
import 'service_history_detail_screen.dart';

class AllServiceHistoryScreen extends StatelessWidget {
  final ServiceHistoryRepository repository;
  AllServiceHistoryScreen({Key? key, ServiceHistoryRepository? repository})
      : repository = repository ?? MockServiceHistoryRepository(),
        super(key: key);

  String getStatusLabel(String status) {
    switch (status) {
      case 'Tamamlandı':
        return 'Tamamlandı';
      case 'Beklemede':
        return 'Beklemede';
      case 'Arızalı':
        return 'Arızalı';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Tamamlandı':
        return const Color(0xFF23408E); // Lacivert
      case 'Beklemede':
       return const Color.fromARGB(255, 223, 238, 20); 
      case 'Arızalı':
        return const Color(0xFFE53935); // Kırmızı
      default:
        return const Color(0xFF23408E);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Tamamlandı':
        return const Color(0xFF23408E); // Lacivert
      case 'Beklemede':
        return Color(0xFFFFD600); // Canlı sarı
      case 'Arızalı':
        return const Color(0xFFE53935); // Kırmızı
      default:
        return const Color(0xFF23408E);
    }
  }

  Color getStatusTextColor(String status) {
    return Colors.white;
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Tamamlandı':
        return Icons.check_circle_rounded;
      case 'Beklemede':
        return Icons.hourglass_bottom_rounded;
      case 'Arızalı':
        return Icons.error_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Servis İşlemleri'),
      ),
      body: FutureBuilder<List<ServiceHistory>>(
        future: repository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }
          final items = snapshot.data!;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = items[index];
              final statusColor = getStatusColor(item.status);
              final statusBgColor = getStatusBgColor(item.status);
              final statusTextColor = getStatusTextColor(item.status);
              final statusIcon = getStatusIcon(item.status);
              final statusLabel = getStatusLabel(item.status);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  leading: Icon(statusIcon, color: const Color(0xFF23408E), size: 32),
                  title: Text('${item.type} - ${item.description}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tarih: ${dateFormat.format(item.date)}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
                      Text('Teknisyen: ${item.technician}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusLabel, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 