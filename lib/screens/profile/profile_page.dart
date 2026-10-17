import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/formatters.dart'; // <-- Tambahan import formatters

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  Future<Uint8List?>? _profileImageFuture;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  // ==========================================
  // 1. AMBIL DATA PROFIL DARI SERVICE
  // ==========================================
  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProfileService.getProfile();
      final photo = data['photo']?.toString();

      Future<Uint8List?>? imgFuture;
      if (photo != null && photo.isNotEmpty) {
        imgFuture = ProfileService.getProfileImage(photo);
      }

      if (!mounted) return;
      setState(() {
        _profile = data;
        _profileImageFuture = imgFuture;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      
      if (msg == 'UNAUTHORIZED') {
        context.go(AppRoutes.login);
      } else {
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // 2. LOGOUT
  // ==========================================
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius)),
        title: Text('Keluar Akun', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.inter(color: AppColors.textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AuthService.logout(); // Hapus token via Service
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, 'Gagal logout', isError: true);
    }
  }

  // ==========================================
  // 3. BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppHeader(
        pageTitle: 'Profile',
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _getProfile,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null || _profile == null) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Gagal memuat profil', textAlign: TextAlign.center, style: GoogleFonts.inter()),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _getProfile,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    // Ambil Data
    final name = _profile!['name']?.toString() ?? '-';
    final username = _profile!['username']?.toString() ?? '-';
    final email = _profile!['email']?.toString() ?? '-';
    final phone = _profile!['phone']?.toString() ?? '-';
    
    String gender = '-';
    if (_profile!['gender'] != null) {
      final g = _profile!['gender'].toString().toLowerCase();
      gender = g.startsWith('l') ? 'Laki-laki' : (g.startsWith('p') ? 'Perempuan' : '-');
    }
    
    final birthPlace = _profile!['birth_place']?.toString() ?? '-';
    
    // PERBAIKAN: Format Tanggal Lahir agar rapi
    final rawBirthDate = _profile!['birth_date']?.toString();
    final birthDate = (rawBirthDate != null && rawBirthDate.isNotEmpty) 
        ? Formatters.dateIndo(rawBirthDate) 
        : '-';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  // CARD UTAMA PROFIL
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Header Banner
                        Container(
                          height: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        
                        // Avatar & Info
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
                            child: Column(
                              children: [
                                _buildAvatar(),
                                const SizedBox(height: 12),
                                Text(
                                  name,
                                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '@$username',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                                const SizedBox(height: 24),

                                // Grid/List Informasi
                                if (isWide) ...[
                                  Row(children: [
                                    Expanded(child: _buildInfoItem(Icons.alternate_email_rounded, 'Email', email)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildInfoItem(Icons.phone_outlined, 'Nomor HP', phone)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Expanded(child: _buildInfoItem(Icons.wc_rounded, 'Jenis Kelamin', gender)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildInfoItem(Icons.location_on_outlined, 'Tempat Lahir', birthPlace)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Expanded(child: _buildInfoItem(Icons.calendar_today_outlined, 'Tanggal Lahir', birthDate)),
                                    const SizedBox(width: 16),
                                    const Expanded(child: SizedBox()), // Spacer
                                  ]),
                                ] else ...[
                                  _buildInfoItem(Icons.alternate_email_rounded, 'Email', email),
                                  const SizedBox(height: 12),
                                  _buildInfoItem(Icons.phone_outlined, 'Nomor HP', phone),
                                  const SizedBox(height: 12),
                                  _buildInfoItem(Icons.wc_rounded, 'Jenis Kelamin', gender),
                                  const SizedBox(height: 12),
                                  _buildInfoItem(Icons.location_on_outlined, 'Tempat Lahir', birthPlace),
                                  const SizedBox(height: 12),
                                  _buildInfoItem(Icons.calendar_today_outlined, 'Tanggal Lahir', birthDate),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL AKSI
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Pindah ke Edit Profil via GoRouter
                        final result = await context.push(AppRoutes.editProfile, extra: _profile);
                        if (result == true) _getProfile(); // Refresh jika berhasil edit
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('Edit Profil', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text('Keluar Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // WIDGET HELPER
  // ==========================================
  Widget _buildAvatar() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.surface, width: 4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipOval(
        child: _profileImageFuture != null
            ? FutureBuilder<Uint8List?>(
                future: _profileImageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  }
                  return const Icon(Icons.person, size: 45, color: AppColors.textMuted);
                },
              )
            : const Icon(Icons.person, size: 45, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}