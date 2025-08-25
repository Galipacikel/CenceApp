import 'package:flutter/material.dart';

/// Base provider class that provides common functionality for all providers
abstract class BaseProvider<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  String? _error;

  /// Getter for items list (immutable)
  List<T> get items => List.unmodifiable(_items);

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for error state
  String? get error => _error;

  /// Getter for items count
  int get count => _items.length;

  /// Getter for empty state
  bool get isEmpty => _items.isEmpty;

  /// Getter for not empty state
  bool get isNotEmpty => _items.isNotEmpty;

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Set all items
  void setItems(List<T> items) {
    _items = List.from(items);
    notifyListeners();
  }

  /// Add single item
  void addItem(T item) {
    _items.add(item);
    notifyListeners();
  }

  /// Add multiple items
  void addItems(List<T> items) {
    _items.addAll(items);
    notifyListeners();
  }

  /// Update item at index
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// Remove item at index
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Remove item by condition
  void removeWhere(bool Function(T) test) {
    _items.removeWhere(test);
    notifyListeners();
  }

  /// Clear all items
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Get item at index
  T? getItem(int index) {
    if (index >= 0 && index < _items.length) {
      return _items[index];
    }
    return null;
  }

  /// Find item by condition
  T? findWhere(bool Function(T) test) {
    try {
      return _items.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Filter items by condition
  List<T> where(bool Function(T) test) {
    return _items.where(test).toList();
  }

  /// Abstract methods that must be implemented by subclasses
  Future<void> fetchAll();
  Future<void> add(T item);
  Future<void> update(String id, T item);
  Future<void> delete(String id);
}
