import 'package:flutter/material.dart';
import '../models/stock_part.dart';

class StockProvider extends ChangeNotifier {
  final List<StockPart> _parts = [
    StockPart(id: '1', parcaAdi: 'Anakart', parcaKodu: '77889', stokAdedi: 1, criticalLevel: 2),
    StockPart(id: '2', parcaAdi: 'Ekran', parcaKodu: '44556', stokAdedi: 3, criticalLevel: 3),
    StockPart(id: '3', parcaAdi: 'Kablo', parcaKodu: '67890', stokAdedi: 5, criticalLevel: 4),
    StockPart(id: '4', parcaAdi: 'Sensör', parcaKodu: '12345', stokAdedi: 10, criticalLevel: 5),
    StockPart(id: '5', parcaAdi: 'Batarya', parcaKodu: '11223', stokAdedi: 20, criticalLevel: 6),
  ];

  List<StockPart> get parts => List.unmodifiable(_parts);

  void updateCriticalLevel(String partId, int newLevel) {
    final index = _parts.indexWhere((p) => p.id == partId);
    if (index != -1) {
      _parts[index].criticalLevel = newLevel;
      notifyListeners();
    }
  }

  void decreaseStock(String partId, int amount) {
    final index = _parts.indexWhere((p) => p.id == partId);
    if (index != -1 && _parts[index].stokAdedi >= amount) {
      _parts[index].stokAdedi -= amount;
      notifyListeners();
    }
  }

  void addPart(StockPart part) {
    _parts.add(part);
    notifyListeners();
  }

  void updatePart(StockPart updatedPart) {
    final index = _parts.indexWhere((p) => p.id == updatedPart.id);
    if (index != -1) {
      _parts[index] = updatedPart;
      notifyListeners();
    }
  }

  void removePart(String partId) {
    _parts.removeWhere((p) => p.id == partId);
    notifyListeners();
  }

  // Kritik parçaları döndür
  List<StockPart> getCriticalParts() {
    return _parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
  }

  // Parçaları güncel sıralama ile döndür (kritikler üstte)
  List<StockPart> getSortedParts() {
    final critical = getCriticalParts();
    final normal = _parts.where((p) => p.stokAdedi > p.criticalLevel).toList();
    return [...critical, ...normal];
  }
} 