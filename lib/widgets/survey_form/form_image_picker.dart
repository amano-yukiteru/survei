import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class FormImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final Future<Uint8List?>? existingImageFuture;
  final bool isEdit;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const FormImagePicker({
    super.key,
    this.imageBytes,
    this.existingImageFuture,
    required this.isEdit,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Jika ada gambar BARU yang dipilih
    if (imageBytes != null) {
      return Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(imageBytes!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                  label: const Text('Ganti Foto'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Hapus'),
              ),
            ],
          ),
        ],
      );
    }

    // 2. Jika Mode Edit dan punya foto lama
    if (isEdit && existingImageFuture != null) {
      return Column(
        children: [
          FutureBuilder<Uint8List?>(
            future: existingImageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
              label: const Text('Ganti dengan Foto Baru'),
            ),
          ),
        ],
      );
    }

    // 3. Jika belum ada foto (Upload Box)
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text('Unggah Foto Survey', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            Text('Ketuk untuk memilih', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}