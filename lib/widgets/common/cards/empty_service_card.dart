import 'package:flutter/material.dart';

class EmptyServiceCard extends StatelessWidget {
  const EmptyServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // küçültüldü
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.2,
        ), // inceltildi
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56, // küçültüldü
            color: Color(0xFFB0B3C0),
          ),
          SizedBox(height: 16), // azaltıldı
          Text(
            'Henüz servis kaydı yok',
            style: TextStyle(
              fontSize: 16, // küçültüldü
              fontWeight: FontWeight.w500,
              color: Color(0xFF6F7489),
            ),
          ),
        ],
      ),
    );
  }
}
