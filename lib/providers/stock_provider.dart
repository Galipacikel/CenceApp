import 'package:flutter/material.dart';
import 'package:cence_app/domain/repositories/stock_part_repository.dart';
import '../models/stock_part.dart';

class StockProvider extends ChangeNotifier {
  final List<StockPart> _parts = [];
  final StockPartRepositoryV2 _repository;
  String? _error;

  StockProvider({required StockPartRepositoryV2 repository}) : _repository = repository;

  List<StockPart> get parts => List.unmodifiable(_parts);
  String? get error => _error;

  Future<void> fetchAll() async {
    final result = await _repository.getAll();
    result.fold(
      onSuccess: (list) {
        _parts
          ..clear()
          ..addAll(list);
        _error = null;
        notifyListeners();
      },
      onFailure: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
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
