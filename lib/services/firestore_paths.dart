class FirestorePaths {
  static const String users = 'users';
  static const String devices = 'devices';
  static const String forms = 'formlar';
  static const String serviceRecords = 'serviceRecords'; // Alt koleksiyon olacak
  static const String serviceRecordsArchive = 'service_records_archive';
  static const String spareParts = 'spareParts'; // Tutarlılık için kebab case kaldırıldı
  
  /// Belirli bir cihaza ait servis kayıtları alt koleksiyonu
  static String deviceServiceRecords(String deviceId) => 
      '$devices/$deviceId/$serviceRecords';
}
