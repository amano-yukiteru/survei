import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../services/profile_service.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final String pageTitle;

  const AppHeader({
    super.key,
    required this.pageTitle,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {
  String _userName = '...'; // Placeholder saat loading
  Future<Uint8List?>? _imageFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Mengambil data dari API secara mandiri
  Future<void> _fetchUserData() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      final photo = profileData['photo'] ?? profileData['image'];
      Future<Uint8List?>? imgFuture;
      if (photo != null && photo.toString().isNotEmpty) {
        imgFuture = ProfileService.getProfileImage(photo.toString());
      }

      if (!mounted) return;
      setState(() {
        _userName = profileData['name'] ?? profileData['username'] ?? 'User';
        _imageFuture = imgFuture;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userName = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
      titleSpacing: 20,
      // KIRI: Nama Halaman
      title: Text(
        widget.pageTitle,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.text,
        ),
      ),
      // KANAN: Nama User & Foto Profil dari API
      actions: [
        Row(
          children: [
            if (_isLoading)
              const SizedBox(
                width: 16, 
                height: 16, 
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
              )
            else
              Text(
                _userName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSub,
                ),
              ),
            const SizedBox(width: 10),
            
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.bg,
              child: ClipOval(
                child: _imageFuture != null
                    ? FutureBuilder<Uint8List?>(
                        future: _imageFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                width: 16, 
                                height: 16, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
                              ),
                            );
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!, 
                              width: 36, 
                              height: 36, 
                              fit: BoxFit.cover
                            );
                          }
                          return const Icon(Icons.person, color: AppColors.textMuted, size: 20);
                        },
                      )
                    : const Icon(Icons.person, color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}