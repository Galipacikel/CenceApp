class StockPart {
  final String id;
  final String parcaAdi;
  final String parcaKodu;
  int stokAdedi;
  final String tedarikci;
  final DateTime sonGuncelleme;

  StockPart({
    required this.id,
    required this.parcaAdi,
    required this.parcaKodu,
    required this.stokAdedi,
    required this.tedarikci,
    required this.sonGuncelleme,
  });

  factory StockPart.fromJson(Map<String, dynamic> json) {
    return StockPart(
      id: json['id'] ?? '',
      parcaAdi: json['parcaAdi'] ?? '',
      parcaKodu: json['parcaKodu'] ?? '',
      stokAdedi: json['stokAdedi'] ?? 0,
      tedarikci: json['tedarikci'] ?? '',
      sonGuncelleme: DateTime.tryParse(json['sonGuncelleme'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcaAdi': parcaAdi,
      'parcaKodu': parcaKodu,
      'stokAdedi': stokAdedi,
      'tedarikci': tedarikci,
      'sonGuncelleme': sonGuncelleme.toIso8601String(),
    };
  }
}

abstract class StockPartRepository {
  Future<List<StockPart>> getAll();
  Future<void> decreaseQuantity(String partCode, int amount);
}

class MockStockRepository implements StockPartRepository {
  final List<StockPart> _mockList = [
    StockPart(
       id: '1',
       parcaAdi: 'Anakart',
       parcaKodu: '77889',
       stokAdedi: 1,
       tedarikci: 'ABC Firması',
       sonGuncelleme: DateTime.parse('2023-08-12'),
     ),
     StockPart(
       id: '2',
       parcaAdi: 'Ekran',
       parcaKodu: '44556',
       stokAdedi: 3,
       tedarikci: 'XYZ Firması',
       sonGuncelleme: DateTime.parse('2023-08-11'),
     ),
     StockPart(
       id: '3',
       parcaAdi: 'Kablo',
       parcaKodu: '67890',
       stokAdedi: 5,
       tedarikci: 'DEF Firması',
       sonGuncelleme: DateTime.parse('2023-08-10'),
     ),
     StockPart(
       id: '4',
       parcaAdi: 'Sensör',
       parcaKodu: '12345',
       stokAdedi: 10,
       tedarikci: 'GHI Firması',
       sonGuncelleme: DateTime.parse('2023-08-09'),
    ),
    StockPart(
       id: '5',
       parcaAdi: 'Batarya',
       parcaKodu: '11223',
       stokAdedi: 20,
       tedarikci: 'JKL Firması',
       sonGuncelleme: DateTime.parse('2023-08-08'),
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
       final newQuantity = (part.stokAdedi - amount).clamp(0, part.stokAdedi);
      _mockList[index] = StockPart(
          id: part.id,
          parcaAdi: part.parcaAdi,
          parcaKodu: part.parcaKodu,
          stokAdedi: newQuantity,
          tedarikci: part.tedarikci,
          sonGuncelleme: DateTime.now(),
      );
    }
  }
} 