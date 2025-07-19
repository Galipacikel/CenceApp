class StockMovement {
  final String type; // 'Giriş' veya 'Çıkış'
  final int amount;
  final String date;
  final String? description;

  StockMovement({
    required this.type,
    required this.amount,
    required this.date,
    this.description,
  });
}

class StockPart {
  final String name;
  final String code;
  final int quantity;
  final String lastUpdate;
  final int criticalLevel;
  final String? description;
  final String? category;
  final List<StockMovement>? movements;

  StockPart({
    required this.name,
    required this.code,
    required this.quantity,
    required this.lastUpdate,
    required this.criticalLevel,
    this.description,
    this.category,
    this.movements,
  });

  factory StockPart.fromJson(Map<String, dynamic> json) {
    return StockPart(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      quantity: json['quantity'] ?? 0,
      lastUpdate: json['lastUpdate'] ?? '',
      criticalLevel: json['criticalLevel'] ?? 0,
      description: json['description'],
      category: json['category'],
      movements: (json['movements'] as List?)?.map((m) => StockMovement(
        type: m['type'],
        amount: m['amount'],
        date: m['date'],
        description: m['description'],
      )).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'quantity': quantity,
      'lastUpdate': lastUpdate,
      'criticalLevel': criticalLevel,
      'description': description,
      'category': category,
      'movements': movements?.map((m) => {
        'type': m.type,
        'amount': m.amount,
        'date': m.date,
        'description': m.description,
      }).toList(),
    };
  }
}

abstract class StockPartRepository {
  Future<List<StockPart>> getAll();
}

class MockStockPartRepository implements StockPartRepository {
  final List<StockPart> _mockList = [
    StockPart(
      name: 'Anakart',
      code: '77889',
      quantity: 1,
      lastUpdate: '12.08.2023',
      criticalLevel: 2,
      description: 'Cihazın ana devre kartı',
      category: 'Elektronik',
      movements: [
        StockMovement(type: 'Giriş', amount: 2, date: '10.08.2023', description: 'Yeni stok girişi'),
        StockMovement(type: 'Çıkış', amount: 1, date: '12.08.2023', description: 'Servise verildi'),
      ],
    ),
    StockPart(
      name: 'Ekran',
      code: '44556',
      quantity: 3,
      lastUpdate: '11.08.2023',
      criticalLevel: 5,
      description: 'LCD ekran',
      category: 'Elektronik',
      movements: [
        StockMovement(type: 'Giriş', amount: 5, date: '05.08.2023', description: 'Toplu alım'),
        StockMovement(type: 'Çıkış', amount: 2, date: '11.08.2023', description: 'Arızalı değişim'),
      ],
    ),
    StockPart(name: 'Kablo', code: '67890', quantity: 5, lastUpdate: '10.08.2023', criticalLevel: 3, description: 'Bağlantı kablosu', category: 'Sarf Malzeme'),
    StockPart(name: 'Sensör', code: '12345', quantity: 10, lastUpdate: '09.08.2023', criticalLevel: 5, description: 'Isı sensörü', category: 'Mekanik'),
    StockPart(name: 'Batarya', code: '11223', quantity: 20, lastUpdate: '08.08.2023', criticalLevel: 10, description: 'Yedek batarya', category: 'Elektronik'),
  ];

  @override
  Future<List<StockPart>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<StockPart>.from(_mockList);
  }
} 