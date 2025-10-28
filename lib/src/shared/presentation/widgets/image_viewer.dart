import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  final String? imageName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showFullScreenOnTap;

  const ImageViewer({
    super.key,
    required this.imagePath,
    this.imageName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.showFullScreenOnTap = true,
  });

  bool get _isFirebaseStorageUrl {
    return imagePath.startsWith('https://firebasestorage.googleapis.com');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showFullScreenOnTap ? () => _showFullScreenImage(context) : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_isFirebaseStorageUrl) {
      // Use CachedNetworkImage for Firebase Storage URLs
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    } else {
      // Use Image.file for local files
      final file = File(imagePath);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
            return _buildErrorWidget();
          }

          return Image.file(
            file,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Image not found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imagePath: imagePath,
          imageName: imageName,
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String? imageName;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    this.imageName,
  });

  bool get _isFirebaseStorageUrl {
    return imagePath.startsWith('https://firebasestorage.googleapis.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          imageName ?? 'Image',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _isFirebaseStorageUrl
              ? CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
