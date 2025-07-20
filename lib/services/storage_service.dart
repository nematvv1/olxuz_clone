import 'dart:typed_data';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static Future<String?> uploadImageToStorage(
    String userId,
    io.File? imageFile,
    Uint8List? webImageBytes,
  ) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('ads_images')
          .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask;

      if (kIsWeb && webImageBytes != null) {
        uploadTask = ref.putData(webImageBytes);
      } else if (!kIsWeb && imageFile != null) {
        uploadTask = ref.putFile(imageFile);
      } else {
        return null;
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: \$e");
      return null;
    }
  }
}
