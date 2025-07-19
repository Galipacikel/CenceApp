class StockPart {
  final String name;
  final String code;
  final int quantity;
  final String lastUpdate;
  final int criticalLevel;
  final String? description;
  final String? category;

  StockPart({
    required this.name,
    required this.code,
    required this.quantity,
    required this.lastUpdate,
    required this.criticalLevel,
    this.description,
    this.category,
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
    };
  }
}

abstract class StockPartRepository {
  Future<List<StockPart>> getAll();
}

class MockStockPartRepository implements StockPartRepository {
  final List<StockPart> _mockList = [
    StockPart(name: 'Anakart', code: '77889', quantity: 1, lastUpdate: '12.08.2023', criticalLevel: 2, description: 'Cihazın ana devre kartı', category: 'Elektronik'),
    StockPart(name: 'Ekran', code: '44556', quantity: 3, lastUpdate: '11.08.2023', criticalLevel: 5, description: 'LCD ekran', category: 'Elektronik'),
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