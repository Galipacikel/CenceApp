class Cihaz {
  final String id;
  final String modelAdi;
  final String seriNumarasi;

  Cihaz({
    required this.id,
    required this.modelAdi,
    required this.seriNumarasi,
  });

  factory Cihaz.fromJson(Map<String, dynamic> json) {
    return Cihaz(
      id: json['id'] ?? '',
      modelAdi: json['modelAdi'] ?? '',
      seriNumarasi: json['seriNumarasi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelAdi': modelAdi,
      'seriNumarasi': seriNumarasi,
    };
  }
}

abstract class CihazRepository {
  Future<List<Cihaz>> getAll();
  Future<void> add(Cihaz cihaz);
}

class MockCihazRepository implements CihazRepository {
  final List<Cihaz> _mockCihazlar = [
    Cihaz(id: 'CIHAZ-001', modelAdi: 'Solunum Cihazı X-2000', seriNumarasi: 'SN-A12345'),
    Cihaz(id: 'CIHAZ-002', modelAdi: 'Defibrilatör Pro-500', seriNumarasi: 'SN-B67890'),
    Cihaz(id: 'CIHAZ-003', modelAdi: 'EKG Monitörü Card-10', seriNumarasi: 'SN-C13579'),
  ];

  @override
  Future<List<Cihaz>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockCihazlar;
  }

  @override
  Future<void> add(Cihaz cihaz) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _mockCihazlar.insert(0, cihaz);
  }
} 