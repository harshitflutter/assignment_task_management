import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

abstract class FirebaseStorageService {
  Future<String> uploadImage(File imageFile, String fileName);
  Future<String> uploadFile(File file, String fileName);
  Future<void> deleteFile(String downloadUrl);
  Future<bool> fileExists(String downloadUrl);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FirebaseStorageServiceImpl({
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _storage = storage,
        _auth = auth;

  @override
  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final nameWithoutExtension = path.basenameWithoutExtension(fileName);
      final uniqueFileName = '${nameWithoutExtension}_$timestamp$extension';

      // Create reference to the file location
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('task_attachments')
          .child(uniqueFileName);

      // Upload the file
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<String> uploadFile(File file, String fileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final nameWithoutExtension = path.basenameWithoutExtension(fileName);
      final uniqueFileName = '${nameWithoutExtension}_$timestamp$extension';

      // Create reference to the file location
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('task_attachments')
          .child(uniqueFileName);

      // Upload the file
      final uploadTask = await ref.putFile(file);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  @override
  Future<void> deleteFile(String downloadUrl) async {
    try {
      // Extract the file path from the download URL
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  @override
  Future<bool> fileExists(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
