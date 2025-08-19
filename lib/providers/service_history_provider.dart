import 'package:flutter/material.dart';
import '../models/service_history.dart';
import '../repositories/firestore_service_history_repository.dart';
import 'base_provider.dart';

class ServiceHistoryProvider extends BaseProvider<ServiceHistory> {
  final FirestoreServiceHistoryRepository _repository =
      FirestoreServiceHistoryRepository();

  List<ServiceHistory> get all => items;

  List<ServiceHistory> getRecent({int count = 3}) {
    return items.take(count).toList();
  }

  // Legacy method for backward compatibility
  void setAll(List<ServiceHistory> list) {
    setItems(list);
  }

  void addServiceHistory(ServiceHistory history) {
    debugPrint('DEBUG: addServiceHistory çağrıldı - ID: ${history.id}');
    addItem(history);
  }

  @override
  Future<void> fetchAll() async {
    setLoading(true);
    try {
      final list = await _repository.getAll();
      setItems(list);
      // Verileri tarihe göre sırala (en yeni en üstte)
      final sortedList = List<ServiceHistory>.from(items);
      sortedList.sort((a, b) => b.date.compareTo(a.date));
      setItems(sortedList);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> add(ServiceHistory item) async {
    setLoading(true);
    try {
      await _repository.add(item);
      addServiceHistory(item);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> update(String id, ServiceHistory item) async {
    setLoading(true);
    try {
      await _repository.update(id, item);
      final index = items.indexWhere((e) => e.id == id);
      if (index != -1) {
        updateItem(index, item);
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> delete(String id) async {
    setLoading(true);
    try {
      await _repository.delete(id);
      removeWhere((e) => e.id == id);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Legacy method for backward compatibility
  void updateLegacy(int idx, Map<String, dynamic> yeni) {
    if (idx < 0 || idx >= items.length) return;
    final eski = items[idx];
    final updatedItem = ServiceHistory(
      id: eski.id,
      date: yeni['tarih'] ?? eski.date,
      deviceId: yeni['cihaz'] ?? eski.deviceId,
      musteri: yeni['musteri'] ?? eski.musteri,
      description: ((yeni['baslik'] ?? '') + (yeni['aciklama'] ?? '')),
      technician: yeni['kisi'] ?? eski.technician,
      status: yeni['durum'] ?? eski.status,
      kullanilanParcalar: eski.kullanilanParcalar,
    );
    updateItem(idx, updatedItem);
  }
}
