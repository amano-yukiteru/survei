import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../routes/app_routes.dart';
import '../../services/profile_service.dart';
import '../../widgets/primary_button.dart';
import '../../utils/snackbar_helper.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? profile;

  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthPlaceController;
  late TextEditingController birthDateController;

  String? gender; // L atau P
  String? apiBirthDate; // YYYY-MM-DD untuk API

  Uint8List? selectedImageBytes;
  String? imageName;
  Future<Uint8List?>? oldProfileImageFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile ?? {};

    nameController = TextEditingController(text: profile['name']?.toString() ?? '');
    emailController = TextEditingController(text: profile['email']?.toString() ?? '');
    phoneController = TextEditingController(text: profile['phone']?.toString() ?? '');
    birthPlaceController = TextEditingController(text: profile['birth_place']?.toString() ?? '');

    // Penanganan Jenis Kelamin
    if (profile['gender'] != null) {
      final g = profile['gender'].toString().toLowerCase();
      if (g.startsWith('l')) {
        gender = 'L';
      } else if (g.startsWith('p')) {
        gender = 'P';
      }
    }

    // Penanganan Tanggal Lahir
    String displayBirthDate = '';
    final String? rawDate = profile['birth_date']?.toString();

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        DateTime? parsedDate;
        if (rawDate.contains('-')) {
          final parts = rawDate.split('-');
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              parsedDate = DateTime.parse(rawDate);
            } else if (parts[2].length == 4) {
              final int day = int.parse(parts[0]);
              final int month = int.parse(parts[1]);
              final int year = int.parse(parts[2]);
              parsedDate = DateTime(year, month, day);
            }
          }
        }

        if (parsedDate != null) {
          final String dayStr = parsedDate.day.toString().padLeft(2, '0');
          final String monthStr = parsedDate.month.toString().padLeft(2, '0');
          final String yearStr = parsedDate.year.toString();

          displayBirthDate = '$dayStr-$monthStr-$yearStr';
          apiBirthDate = '$yearStr-$monthStr-$dayStr';
        } else {
          displayBirthDate = rawDate;
          apiBirthDate = rawDate;
        }
      } catch (_) {
        displayBirthDate = rawDate;
        apiBirthDate = rawDate;
      }
    }
    birthDateController = TextEditingController(text: displayBirthDate);

    final oldPhoto = profile['photo']?.toString();
    if (oldPhoto != null && oldPhoto.isNotEmpty) {
      // Menggunakan ProfileService
      oldProfileImageFuture = ProfileService.getProfileImage(oldPhoto);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthPlaceController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        setState(() {
          selectedImageBytes = bytes;
          imageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, 'Gagal mengambil gambar dari galeri.', isError: true);
    }
  }

  Future<void> selectBirthDate() async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 10));
    if (apiBirthDate != null && apiBirthDate!.isNotEmpty) {
      try {
        initialDate = DateTime.parse(apiBirthDate!);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String day = picked.day.toString().padLeft(2, '0');
      final String month = picked.month.toString().padLeft(2, '0');
      final String year = picked.year.toString();

      setState(() {
        birthDateController.text = '$day-$month-$year';
        apiBirthDate = '$year-$month-$day';
      });
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (gender == null) {
      SnackbarHelper.show(context, 'Silakan pilih jenis kelamin.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final fields = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': gender!,
        'birth_place': birthPlaceController.text.trim(),
      };

      if (apiBirthDate != null) {
        fields['birth_date'] = apiBirthDate!;
      }

      // Panggil Service API
      await ProfileService.updateProfile(
        fields: fields,
        imageBytes: selectedImageBytes,
        imageName: imageName,
      );

      if (!mounted) return;
      
      SnackbarHelper.show(context, 'Profil berhasil diperbarui.');
      context.pop(true); // Kembali ke halaman profil & refresh
      
    } catch (e) {
      if (!mounted) return;
      
      final msg = e.toString().replaceAll('Exception: ', '');
      
      if (msg == 'UNAUTHORIZED') {
        context.go(AppRoutes.login);
      } else {
        SnackbarHelper.show(context, msg, isError: true);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =========================================================
  // UI PRESENTATION LAYER
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
       appBar: const AppHeader(
        pageTitle: 'Edit Profile',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Simpan Perubahan',
                      isLoading: isLoading,
                      onPressed: saveProfile,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final oldPhoto = widget.profile?['photo']?.toString();

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: selectedImageBytes != null
                      ? Image.memory(selectedImageBytes!, width: 100, height: 100, fit: BoxFit.cover)
                      : (oldPhoto != null && oldPhoto.isNotEmpty
                          ? FutureBuilder<Uint8List?>(
                              future: oldProfileImageFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                                }
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.memory(snapshot.data!, width: 100, height: 100, fit: BoxFit.cover);
                                }
                                return const Icon(Icons.person_rounded, size: 50, color: AppColors.textMuted);
                              },
                            )
                          : const Icon(Icons.person_rounded, size: 50, color: AppColors.textMuted)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isLoading ? null : pickImage,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ketuk ikon kamera untuk ubah foto',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Nama Lengkap'),
          const SizedBox(height: 6),
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            style: _inputTextStyle(),
            decoration: _inputDecoration(hintText: 'Nama lengkap Anda', prefixIcon: Icons.person_outline_rounded),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            style: _inputTextStyle(),
            decoration: _inputDecoration(hintText: 'alamat@email.com', prefixIcon: Icons.alternate_email_rounded),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
              if (!value.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Nomor HP'),
          const SizedBox(height: 6),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            style: _inputTextStyle(),
            decoration: _inputDecoration(hintText: '08xxxxxxxxxx', prefixIcon: Icons.phone_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Jenis Kelamin'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: gender,
            style: _inputTextStyle(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSub),
            decoration: _inputDecoration(hintText: 'Pilih jenis kelamin', prefixIcon: Icons.wc_rounded),
            dropdownColor: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            items: [
              DropdownMenuItem(value: 'L', child: Text('Laki-laki', style: _inputTextStyle())),
              DropdownMenuItem(value: 'P', child: Text('Perempuan', style: _inputTextStyle())),
            ],
            onChanged: isLoading ? null : (value) => setState(() => gender = value),
            validator: (value) => value == null ? 'Jenis kelamin wajib dipilih' : null,
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Tempat Lahir'),
          const SizedBox(height: 6),
          TextFormField(
            controller: birthPlaceController,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            style: _inputTextStyle(),
            decoration: _inputDecoration(hintText: 'Kota tempat Anda lahir', prefixIcon: Icons.location_on_outlined),
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Tanggal Lahir'),
          const SizedBox(height: 6),
          TextFormField(
            controller: birthDateController,
            readOnly: true,
            enabled: !isLoading,
            onTap: isLoading ? null : selectBirthDate,
            style: _inputTextStyle(),
            decoration: _inputDecoration(hintText: 'Pilih tanggal lahir', prefixIcon: Icons.calendar_today_outlined),
            validator: (value) => (value == null || value.isEmpty) ? 'Tanggal lahir wajib dipilih' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSub,
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.text,
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSub),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
    );
  }
}