import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/features/tasks/data/services/file_attachment_service.dart';
import 'package:task_management/src/features/tasks/data/services/firebase_storage_service.dart';
import 'package:task_management/src/shared/presentation/widgets/image_viewer.dart';
import 'package:task_management/src/core/utils/file_type_utils.dart';

class AttachmentPicker extends StatelessWidget {
  final String? attachmentPath;
  final String? attachmentName;
  final Function(String?, String?) onAttachmentChanged;

  const AttachmentPicker({
    super.key,
    required this.attachmentPath,
    required this.attachmentName,
    required this.onAttachmentChanged,
  });

  FileAttachmentService get _fileService => FileAttachmentServiceImpl(
        imagePicker: ImagePicker(),
        filePicker: FilePicker.platform,
        firebaseStorageService: FirebaseStorageServiceImpl(
          storage: FirebaseStorage.instance,
          auth: FirebaseAuth.instance,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attachmentPath != null) ...[
          // Show current attachment
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.fieldShadow,
              ),
              color: AppColors.formBackground,
            ),
            child: Column(
              children: [
                // Show image preview if it's an image
                if (FileTypeUtils.isImage(attachmentPath) ||
                    FileTypeUtils.isImageByAttachmentName(attachmentName)) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImageViewer(
                      imagePath: attachmentPath!,
                      imageName: attachmentName,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      showFullScreenOnTap: true,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // File info row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _previewFile(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FileTypeUtils.getFileIcon(attachmentName ?? ''),
                          color: AppColors.purple,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _previewFile(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachmentName ?? 'Unknown file',
                              style: AppTextStyles.primary400Size16,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getPreviewText(),
                              style: AppTextStyles.hint500Size12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // Attachment buttons
        Row(
          children: [
            Expanded(
              child: _buildAttachmentButton(
                context: context,
                icon: Icons.image_outlined,
                label: 'Add Image',
                color: AppColors.purple,
                onTap: () => _pickImage(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildAttachmentButton(
                context: context,
                icon: Icons.attach_file_outlined,
                label: 'Add File',
                color: AppColors.white,
                onTap: () => _pickFile(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.grey.withOpacity(0.3),
            ),
            color: AppColors.white.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.purple,
                  size: 24,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTextStyles.primary400Size16,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await _fileService.pickImage();
      if (result != null && context.mounted) {
        onAttachmentChanged(result['path'], result['name']);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await _fileService.pickFile();
      if (result != null && context.mounted) {
        onAttachmentChanged(result['path'], result['name']);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick file: $e');
      }
    }
  }

  String _getPreviewText() {
    if (attachmentPath == null) return 'No attachment';

    final isImageFile = FileTypeUtils.isImage(attachmentPath) ||
        FileTypeUtils.isImageByAttachmentName(attachmentName);

    if (isImageFile) {
      return 'Tap to view full screen';
    } else {
      return 'Tap to open file';
    }
  }

  Future<void> _previewFile(BuildContext context) async {
    if (attachmentPath == null) return;

    try {
      final isImageFile = FileTypeUtils.isImage(attachmentPath) ||
          FileTypeUtils.isImageByAttachmentName(attachmentName);

      if (isImageFile) {
        // For images, show full screen viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imagePath: attachmentPath!,
              imageName: attachmentName,
            ),
          ),
        );
      } else {
        // For non-image files, use open_file package
        if (attachmentPath!.startsWith('https://')) {
          // For Firebase Storage URLs, download and open
          await _openFirebaseFile(context);
        } else {
          // For local files, open directly
          final result = await OpenFile.open(attachmentPath!);
          if (result.type != ResultType.done && context.mounted) {
            _showErrorSnackBar(
                context, 'Failed to open file: ${result.message}');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to preview file: $e');
      }
    }
  }

  Future<void> _openFirebaseFile(BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading file from cloud storage...'),
            backgroundColor: AppColors.purple,
          ),
        );
      }

      // Download file from Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(attachmentPath!);
      final bytes = await ref.getData();

      if (bytes == null) {
        throw Exception('Failed to download file from Firebase Storage');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = attachmentName ?? 'temp_file';
      final tempFile = File('${tempDir.path}/$fileName');

      // Write bytes to temporary file
      await tempFile.writeAsBytes(bytes);

      // Open the downloaded file
      final result = await OpenFile.open(tempFile.path);

      if (result.type != ResultType.done && context.mounted) {
        _showErrorSnackBar(context, 'Failed to open file: ${result.message}');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File opened successfully'),
            backgroundColor: AppColors.green,
          ),
        );
      }

      // Clean up temporary file after a delay
      Future.delayed(const Duration(minutes: 5), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open cloud file: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }
}
