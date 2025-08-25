/// Centralized Firestore collection/document paths
class FbPaths {
  FbPaths._();

  // Collections
  static const users = 'users';
  static const devices = 'devices';
  static const serviceHistory = 'service_history';
  static const stockParts = 'stock_parts';
  static const appSettings = 'app_settings';

  // Helpers
  static String userDoc(String uid) => '$users/$uid';
  static String deviceDoc(String id) => '$devices/$id';
  static String serviceHistoryDoc(String id) => '$serviceHistory/$id';
  static String stockPartDoc(String id) => '$stockParts/$id';
}
