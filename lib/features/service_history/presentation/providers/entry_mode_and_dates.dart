import 'package:flutter_riverpod/flutter_riverpod.dart';

// Arıza sekmesi için giriş modu (manuel / otomatik)
final manualEntryProvider = StateProvider<bool>((ref) => false);

// Opsiyonel servis başlangıç/bitiş tarihleri
final serviceStartDateProvider = StateProvider<DateTime?>((ref) => null);
final serviceEndDateProvider = StateProvider<DateTime?>((ref) => null);


