class StockPart {
  final String id;
  final String parcaAdi;
  final String parcaKodu;
  int stokAdedi;

  StockPart({
    required this.id,
    required this.parcaAdi,
    required this.parcaKodu,
    required this.stokAdedi,
  });

  factory StockPart.fromJson(Map<String, dynamic> json) {
    return StockPart(
      id: json['id'] ?? '',
      parcaAdi: json['parcaAdi'] ?? '',
      parcaKodu: json['parcaKodu'] ?? '',
      stokAdedi: json['stokAdedi'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcaAdi': parcaAdi,
      'parcaKodu': parcaKodu,
      'stokAdedi': stokAdedi,
    };
  }
}

abstract class StockPartRepository {
  Future<List<StockPart>> getAll();
  Future<void> decreaseQuantity(String partCode, int amount);
}

class MockStockRepository implements StockPartRepository {
  static final MockStockRepository _instance = MockStockRepository._internal();

  factory MockStockRepository() {
    return _instance;
  }

  MockStockRepository._internal();

  final List<StockPart> _mockList = [
    StockPart(
       id: '1',
       parcaAdi: 'Anakart',
       parcaKodu: '77889',
       stokAdedi: 1,
     ),
     StockPart(
       id: '2',
       parcaAdi: 'Ekran',
       parcaKodu: '44556',
       stokAdedi: 3,
     ),
     StockPart(
       id: '3',
       parcaAdi: 'Kablo',
       parcaKodu: '67890',
       stokAdedi: 5,
     ),
     StockPart(
       id: '4',
       parcaAdi: 'Sensör',
       parcaKodu: '12345',
       stokAdedi: 10,
    ),
    StockPart(
       id: '5',
       parcaAdi: 'Batarya',
       parcaKodu: '11223',
       stokAdedi: 20,
     ),
  ];

  @override
  Future<List<StockPart>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockList;
  }

  @override
  Future<void> decreaseQuantity(String partCode, int amount) async {
     final index = _mockList.indexWhere((part) => part.parcaKodu == partCode);
    if (index != -1) {
      final part = _mockList[index];
      if (part.stokAdedi >= amount) {
        part.stokAdedi -= amount;
      }
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }
} 