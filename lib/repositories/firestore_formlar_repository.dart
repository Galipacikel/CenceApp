import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/models/service_history.dart';

class FirestoreFormlarRepository {
  final FirebaseFirestore _firestore;

  FirestoreFormlarRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Result<List<ServiceHistory>, Exception>> getAll() async {
    try {
      final snapshot = await _firestore.collection('formlar').get();
      
      final formlarList = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Formlar koleksiyonundaki veriyi ServiceHistory formatına dönüştür
        return ServiceHistory(
          id: doc.id,
          serialNumber: _parseField(data['SERİ NO']),
          deviceName: _parseField(data['CİHAZ ADI']),
          brand: _parseField(data['MARKA']),
          model: _parseField(data['MODEL']),
          musteri: _parseField(data['FİRMA']),
          location: _parseField(data['LOKASYON']),
          status: 'Eski Formlar', // Özel durum etiketi
          description: _parseField(data['YAPILAN İŞLEM']),
          technician: 'Eski Kayıt',
          date: _parseDate(data['TARİH']),
          kullanilanParcalar: [],
          photos: [],
        );
      }).toList();

      return Result.ok(formlarList);
    } catch (e) {
      return Result.err(Exception('Formlar verileri alınırken hata: $e'));
    }
  }

  String _parseField(dynamic field) {
    if (field == null) return '';
    return field.toString();
  }

  DateTime _parseDate(dynamic dateField) {
    if (dateField == null) return DateTime.now();
    
    if (dateField is Timestamp) {
      return dateField.toDate();
    }
    
    if (dateField is String) {
      try {
        return DateTime.parse(dateField);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }
}