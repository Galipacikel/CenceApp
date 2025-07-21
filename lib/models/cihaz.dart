class Cihaz {
  final String id;
  final String modelAdi;
  final String seriNumarasi;
  final String musteriBilgisi;
  final DateTime kurulumTarihi;

  Cihaz({
    required this.id,
    required this.modelAdi,
    required this.seriNumarasi,
    required this.musteriBilgisi,
    required this.kurulumTarihi,
  });

  factory Cihaz.fromJson(Map<String, dynamic> json) {
    return Cihaz(
      id: json['id'] ?? '',
      modelAdi: json['modelAdi'] ?? '',
      seriNumarasi: json['seriNumarasi'] ?? '',
      musteriBilgisi: json['musteriBilgisi'] ?? '',
      kurulumTarihi: DateTime.tryParse(json['kurulumTarihi'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelAdi': modelAdi,
      'seriNumarasi': seriNumarasi,
      'musteriBilgisi': musteriBilgisi,
      'kurulumTarihi': kurulumTarihi.toIso8601String(),
    };
  }
}

// Cihaz verilerini yönetmek için abstract class (repository pattern)
abstract class CihazRepository {
  Future<List<Cihaz>> getAll();
  Future<void> add(Cihaz cihaz);
  // Gelecekte eklenebilir: update, delete, getById
}

// Mock verilerle CihazRepository'nin somut bir uygulaması
class MockCihazRepository implements CihazRepository {
  final List<Cihaz> _mockCihazlar = [
    Cihaz(id: 'CIHAZ-001', modelAdi: 'Solunum Cihazı X-2000', seriNumarasi: 'SN-A12345', musteriBilgisi: 'A Hastanesi', kurulumTarihi: DateTime(2023, 5, 15)),
    Cihaz(id: 'CIHAZ-002', modelAdi: 'Defibrilatör Pro-500', seriNumarasi: 'SN-B67890', musteriBilgisi: 'B Kliniği', kurulumTarihi: DateTime(2022, 11, 20)),
    Cihaz(id: 'CIHAZ-003', modelAdi: 'EKG Monitörü Card-10', seriNumarasi: 'SN-C13579', musteriBilgisi: 'C Sağlık Merkezi', kurulumTarihi: DateTime(2024, 1, 30)),
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