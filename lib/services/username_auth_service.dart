import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_paths.dart';

class UsernameAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UsernameAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Kullanıcı adına göre email adresini bulur
  Future<String?> findEmailByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.users)
          .where('username_lowercase', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        return userData['email'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Kullanıcı adı ile giriş yapar
  Future<UserCredential?> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // Önce kullanıcı adına göre email'i bul
      final email = await findEmailByUsername(username);

      if (email != null) {
        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      // Kullanıcı adı bulunamazsa ve giriş değeri e-posta formatındaysa e-posta ile dene
      final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
      if (emailRegex.hasMatch(username)) {
        return await _auth.signInWithEmailAndPassword(
          email: username,
          password: password,
        );
      }

      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Bu kullanıcı adı ile kayıtlı bir hesap bulunamadı.',
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Bilinmeyen bir hata oluştu: $e',
      );
    }
  }

  /// Kullanıcı adının uygunluğunu kontrol eder
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.users)
          .where('username_lowercase', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Kullanıcı adı formatını kontrol eder
  bool isValidUsername(String username) {
    // 3-20 karakter, sadece harf, rakam ve alt çizgi
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return regex.hasMatch(username);
  }

  /// Yeni kullanıcı oluşturur (email + kullanıcı adı ile)
  Future<UserCredential?> createUserWithUsernameAndEmail({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String role = 'technician',
  }) async {
    try {
      // Kullanıcı adı formatını kontrol et
      if (!isValidUsername(username)) {
        throw FirebaseAuthException(
          code: 'invalid-username',
          message: 'Kullanıcı adı 3-20 karakter olmalı ve sadece harf, rakam, alt çizgi içerebilir.',
        );
      }

      // Kullanıcı adı müsait mi kontrol et
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'Bu kullanıcı adı zaten kullanımda.',
        );
      }

      // Firebase Auth ile kullanıcı oluştur
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'da kullanıcı belgesi oluştur
      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestore.collection(FirestorePaths.users).doc(uid).set({
          'email': email,
          'full_name': fullName,
          'role': role, // legacy için tutuluyor
          'is_admin': role == 'admin', // yeni boolean alan
          'username': username,
          'username_lowercase': username.toLowerCase(),
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Bilinmeyen bir hata oluştu: $e',
      );
    }
  }
}