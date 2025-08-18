class StockPart {
  final String id;
  final String parcaAdi;
  final String parcaKodu;
  int stokAdedi;
  int criticalLevel;

  StockPart({
    required this.id,
    required this.parcaAdi,
    required this.parcaKodu,
    required this.stokAdedi,
    required this.criticalLevel,
  });

  factory StockPart.fromJson(Map<String, dynamic> json) {
    return StockPart(
      id: json['id'] ?? '',
      parcaAdi: json['parcaAdi'] ?? '',
      parcaKodu: json['parcaKodu'] ?? '',
      stokAdedi: json['stokAdedi'] ?? 0,
      criticalLevel: json['criticalLevel'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcaAdi': parcaAdi,
      'parcaKodu': parcaKodu,
      'stokAdedi': stokAdedi,
      'criticalLevel': criticalLevel,
    };
  }
}

abstract class StockPartRepository {
  Future<List<StockPart>> getAll();
  Future<void> decreaseQuantity(String partCode, int amount);
}
