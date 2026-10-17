import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class DetailPhotoCard extends StatelessWidget {
  final Future<Uint8List?>? imageFuture;
  final String title;

  const DetailPhotoCard({super.key, this.imageFuture, required this.title});

  // Fungsi untuk Zoom Gambar
  void _showZoomDialog(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada foto di database
    if (imageFuture == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 32),
            const SizedBox(height: 8),
            Text('Foto tidak tersedia', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    // Jika ada foto, tampilkan dengan FutureBuilder
    return FutureBuilder<Uint8List?>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return GestureDetector(
            onTap: () => _showZoomDialog(context, snapshot.data!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return const SizedBox(); // Fallback jika error
      },
    );
  }
}