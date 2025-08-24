import 'package:flutter/material.dart';
import 'package:cence_app/domain/repositories/service_history_repository.dart';
import '../models/service_history.dart';
import 'base_provider.dart';

class ServiceHistoryProvider extends BaseProvider<ServiceHistory> {
  final ServiceHistoryRepositoryV2 _repository;

  ServiceHistoryProvider({required ServiceHistoryRepositoryV2 repository}) : _repository = repository;

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
      final result = await _repository.getAll();
      result.fold(
        onSuccess: (list) {
          setItems(list);
          final sortedList = List<ServiceHistory>.from(items);
          sortedList.sort((a, b) => b.date.compareTo(a.date));
          setItems(sortedList);
        },
        onFailure: (failure) => setError(failure.message),
      );
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> add(ServiceHistory item) async {
    setLoading(true);
    try {
      final result = await _repository.add(item);
      result.fold(
        onSuccess: (_) => addServiceHistory(item),
        onFailure: (failure) => setError(failure.message),
      );
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> update(String id, ServiceHistory item) async {
    setLoading(true);
    try {
      final result = await _repository.update(id, item);
      result.fold(
        onSuccess: (_) {
          final index = items.indexWhere((e) => e.id == id);
          if (index != -1) {
            updateItem(index, item);
          }
        },
        onFailure: (failure) => setError(failure.message),
      );
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> delete(String id) async {
    setLoading(true);
    try {
      final result = await _repository.delete(id);
      result.fold(
        onSuccess: (_) => removeWhere((e) => e.id == id),
        onFailure: (failure) => setError(failure.message),
      );
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
