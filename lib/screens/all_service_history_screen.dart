import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_history.dart';
import 'service_history_detail_screen.dart';

class AllServiceHistoryScreen extends StatelessWidget {
  final ServiceHistoryRepository repository;
  AllServiceHistoryScreen({Key? key, ServiceHistoryRepository? repository})
      : repository = repository ?? MockServiceHistoryRepository(),
        super(key: key);

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
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ServiceHistoryDetailScreen(serviceHistory: item),
                    ),
                  );
                },
                title: Text('${item.type} - ${item.description}', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarih: ${dateFormat.format(item.date)}'),
                    Text('Teknisyen: ${item.technician}'),
                  ],
                ),
                trailing: _StatusChip(status: item.status),
              );
            },
          );
        },
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