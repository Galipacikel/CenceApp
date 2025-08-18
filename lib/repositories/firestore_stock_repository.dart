import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_part.dart';
import '../services/firestore_paths.dart';

class FirestoreStockRepository implements StockPartRepository {
  final FirebaseFirestore _firestore;

  FirestoreStockRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<StockPart>> getAll() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.spareParts)
        .get();
    return snapshot.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<void> decreaseQuantity(String partCode, int amount) async {
    // Here partCode is assumed to be the document id; adjust if using stock_code instead
    final docRef = _firestore
        .collection(FirestorePaths.spareParts)
        .doc(partCode);
    await docRef.update({
      'stock_quantity': FieldValue.increment(-1 * amount),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  StockPart _fromFirestore(String id, Map<String, dynamic> data) {
    return StockPart(
      id: id,
      parcaAdi: (data['part_name'] ?? data['name'] ?? '') as String,
      parcaKodu: (data['stock_code'] ?? '') as String,
      stokAdedi: (data['stock_quantity'] ?? 0) as int,
      criticalLevel: 0,
    );
  }
}
