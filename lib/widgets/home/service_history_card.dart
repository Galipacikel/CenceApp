import 'package:flutter/material.dart';
import 'package:cence_app/screens/all_service_history_screen.dart';
import 'package:cence_app/models/service_history.dart';

class ServiceHistoryCard extends StatelessWidget {
  final VoidCallback? onSeeAll;
  final ServiceHistoryRepository repository;
  ServiceHistoryCard({Key? key, this.onSeeAll, ServiceHistoryRepository? repository})
      : repository = repository ?? MockServiceHistoryRepository(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSeeAll,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Son Servis İşlemleri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF23408E),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AllServiceHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Tümünü Gör',
                        style: TextStyle(
                          color: Color(0xFF23408E),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<ServiceHistory>>(
                future: repository.getRecent(count: 3),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Kayıt bulunamadı.');
                  }
                  final items = snapshot.data!;
                  return Column(
                    children: items.map((item) => _ServiceItem(
                      title: '${item.deviceId} - ${item.description}',
                      serial: '',
                      status: item.status,
                      statusColor: _getStatusColor(item.status),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;
  final String serial;
  final String status;
  final Color statusColor;

  const _ServiceItem({
    required this.title,
    required this.serial,
    required this.status,
    required this.statusColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                
                Text(
                  'Seri No: $serial',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'Başarılı':
      return const Color(0xFF43A047);
    case 'Beklemede':
      return const Color(0xFFFFB300);
    case 'Arızalı':
      return const Color(0xFFE53935);
    default:
      return const Color(0xFFBDBDBD);
  }
} 