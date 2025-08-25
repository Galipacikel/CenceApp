import 'package:flutter/material.dart';
import '../../../models/service_history.dart';
import '../../../screens/service_history_detail_screen.dart';

class ModernServiceCard extends StatelessWidget {
  final ServiceHistory item;

  const ModernServiceCard({super.key, required this.item});

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
          'label': item.status,
          'color': Colors.grey.shade800,
          'bgColor': Colors.grey.shade200,
          'icon': Icons.info_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusData(item.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ServiceHistoryDetailScreen(serviceHistory: item),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey.shade100, width: 1.2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15), // 0.06 * 255 ≈ 15
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            leading: Icon(
              statusData['icon'],
              color: statusData['color'],
              size: 32,
            ),
            title: Text(
              '${item.deviceId} - ${item.description}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1C1C1C),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Teknisyen: ${item.technician}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusData['bgColor'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusData['label'],
                style: TextStyle(
                  color: statusData['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
