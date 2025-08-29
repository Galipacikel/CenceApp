import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadFile({
    required XFile file,
    required String storagePath,
  }) async {
    final ref = _storage.ref(storagePath);
    final Uint8List bytes = await file.readAsBytes();
    // Ensure contentType is set so images render correctly across platforms
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final task = await ref.putData(bytes, metadata);
    final url = await task.ref.getDownloadURL();
    return url;
  }
}
