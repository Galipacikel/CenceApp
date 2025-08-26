import 'package:flutter/material.dart';
import '../models/stock_part.dart';
import '../repositories/firestore_stock_repository.dart';

class StockProvider extends ChangeNotifier {
  final List<StockPart> _parts = [];
  final FirestoreStockRepository _repository = FirestoreStockRepository();

  List<StockPart> get parts => List.unmodifiable(_parts);

  Future<void> fetchAll() async {
    final list = await _repository.getAll();
    _parts
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

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
