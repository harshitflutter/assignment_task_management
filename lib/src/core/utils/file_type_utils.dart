import 'package:flutter/material.dart';

class FileTypeUtils {
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'svg'
  ];

  static bool isImage(String? filePath) {
    if (filePath == null || filePath.isEmpty) return false;

    // Check if it's a Firebase Storage URL
    if (filePath.startsWith('https://firebasestorage.googleapis.com')) {
      // For Firebase Storage URLs, check if it contains image-related keywords
      // or check the attachmentName if available
      return _isFirebaseStorageImage(filePath);
    }

    // For local file paths, check extension
    final extension = filePath.toLowerCase().split('.').last;
    return imageExtensions.contains(extension);
  }

  static bool _isFirebaseStorageImage(String firebaseUrl) {
    // Check if the URL contains image-related patterns
    final url = firebaseUrl.toLowerCase();

    // Check for common image file extensions in the URL
    for (final ext in imageExtensions) {
      if (url.contains('.$ext') || url.contains('_$ext')) {
        return true;
      }
    }

    // Check for image-related keywords in the URL
    final imageKeywords = ['image', 'photo', 'picture', 'img'];
    for (final keyword in imageKeywords) {
      if (url.contains(keyword)) {
        return true;
      }
    }

    // Default to true for Firebase Storage URLs if we can't determine
    // This ensures images are displayed even if URL doesn't contain clear indicators
    return true;
  }

  static bool isImageByAttachmentName(String? attachmentName) {
    if (attachmentName == null || attachmentName.isEmpty) return false;

    final extension = getFileExtension(attachmentName);
    return imageExtensions.contains(extension);
  }

  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(lastDot + 1).toLowerCase() : '';
  }

  static String getFileNameWithoutExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  static IconData getFileIcon(String fileName) {
    final extension = getFileExtension(fileName);

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }
}
