import 'package:flutter/material.dart';
import '../models/service_history.dart';
import '../repositories/firestore_service_history_repository.dart';

class ServiceHistoryProvider extends ChangeNotifier {
  final List<ServiceHistory> _serviceHistoryList = [];
  final FirestoreServiceHistoryRepository _repository =
      FirestoreServiceHistoryRepository();

  List<ServiceHistory> get all => List.unmodifiable(_serviceHistoryList);

  List<ServiceHistory> getRecent({int count = 3}) {
    return _serviceHistoryList.take(count).toList();
  }

  void addServiceHistory(ServiceHistory history) {
    debugPrint('DEBUG: addServiceHistory çağrıldı - ID: ${history.id}');
    _serviceHistoryList.insert(0, history);
    notifyListeners();
  }

  Future<void> fetchAll() async {
    final list = await _repository.getAll();
    setAll(list);
  }

  void setAll(List<ServiceHistory> list) {
    _serviceHistoryList
      ..clear()
      ..addAll(list);

    // Verileri tarihe göre sırala (en yeni en üstte)
    _serviceHistoryList.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  void clear() {
    _serviceHistoryList.clear();
    notifyListeners();
  }

  // Mock yükleme kaldırıldı

  void update(int idx, Map<String, dynamic> yeni) {
    if (idx < 0 || idx >= _serviceHistoryList.length) return;
    final eski = _serviceHistoryList[idx];
    _serviceHistoryList[idx] = ServiceHistory(
      id: eski.id,
      date: yeni['tarih'] ?? eski.date,
      deviceId: yeni['cihaz'] ?? eski.deviceId,
      musteri: yeni['musteri'] ?? eski.musteri,
      description: ((yeni['baslik'] ?? '') + (yeni['aciklama'] ?? '')),
      technician: yeni['kisi'] ?? eski.technician,
      status: yeni['durum'] ?? eski.status,
      kullanilanParcalar: eski.kullanilanParcalar,
    );
    notifyListeners();
  }

  void delete(String id) {
    _serviceHistoryList.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
