import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_management/src/features/tasks/data/services/firebase_storage_service.dart';

abstract class FileAttachmentService {
  Future<Map<String, String>?> pickImage();
  Future<Map<String, String>?> pickFile();
  Future<String> saveFileToLocal(File file, String fileName);
  Future<void> deleteFile(String filePath);
  Future<bool> fileExists(String filePath);
  Future<String> uploadImageToFirebase(File imageFile, String fileName);
  Future<String> uploadFileToFirebase(File file, String fileName);
  Future<void> deleteFileFromFirebase(String downloadUrl);
}

class FileAttachmentServiceImpl implements FileAttachmentService {
  final ImagePicker _imagePicker;
  final FilePicker _filePicker;
  final FirebaseStorageService _firebaseStorageService;

  FileAttachmentServiceImpl({
    required ImagePicker imagePicker,
    required FilePicker filePicker,
    required FirebaseStorageService firebaseStorageService,
  })  : _imagePicker = imagePicker,
        _filePicker = filePicker,
        _firebaseStorageService = firebaseStorageService;

  @override
  Future<Map<String, String>?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final savedPath =
            await saveFileToLocal(File(image.path), _getFileName(image.path));
        return {
          'path': savedPath,
          'name': _getFileName(image.path),
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  @override
  Future<Map<String, String>?> pickFile() async {
    try {
      FilePickerResult? result = await _filePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        final savedPath = await saveFileToLocal(file, fileName);
        return {
          'path': savedPath,
          'name': fileName,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  @override
  Future<String> saveFileToLocal(File file, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${directory.path}/task_attachments');

      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(fileName);
      final nameWithoutExtension = _getFileNameWithoutExtension(fileName);
      final newFileName = '${nameWithoutExtension}_$timestamp$extension';

      final newFile = File('${attachmentsDir.path}/$newFileName');
      await file.copy(newFile.path);

      return newFile.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  String _getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(lastDot) : '';
  }

  String _getFileNameWithoutExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  @override
  Future<String> uploadImageToFirebase(File imageFile, String fileName) async {
    return await _firebaseStorageService.uploadImage(imageFile, fileName);
  }

  @override
  Future<String> uploadFileToFirebase(File file, String fileName) async {
    return await _firebaseStorageService.uploadFile(file, fileName);
  }

  @override
  Future<void> deleteFileFromFirebase(String downloadUrl) async {
    await _firebaseStorageService.deleteFile(downloadUrl);
  }
}
