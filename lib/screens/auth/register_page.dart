import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _gender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // REGISTER LOGIC (MENGGUNAKAN AUTH SERVICE)
  // ============================================================
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      SnackbarHelper.show(context, 'Silakan pilih jenis kelamin.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil AuthService
      await AuthService.register(
        name: _nameController.text.trim(),
        gender: _gender!,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      
      SnackbarHelper.show(context, 'Registrasi berhasil. Silakan login.');
      context.go(AppRoutes.login);
      
    } catch (e) {
      if (!mounted) return;
      
      final msg = e.toString().replaceFirst('Exception: ', '');
      SnackbarHelper.show(context, msg, isError: true);
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _branding(),
                    const SizedBox(height: 26),
                    _card(),
                    const SizedBox(height: 20),
                    _loginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BRANDING
  // ============================================================
  Widget _branding() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Text(
          'DAFTAR AKUN',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Lengkapi Data Diri Anda',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSub,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CARD FORM
  // ============================================================
  Widget _card() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Registrasi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Isi data berikut untuk membuat akun baru',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 22),

          // CustomTextField 1 (Nama)
          CustomTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline_rounded,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            validator: (v) => Validators.required(v, 'Nama Lengkap'),
          ),
          const SizedBox(height: 18),

          // Field Jenis Kelamin
          _genderField(),
          const SizedBox(height: 18),

          // CustomTextField 2 (Email)
          CustomTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.alternate_email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            validator: Validators.email,
          ),
          const SizedBox(height: 18),

          // CustomTextField 3 (Nomor WA)
          CustomTextField(
            label: 'Nomor WhatsApp',
            hint: '08xxxxxxxxxx',
            prefixIcon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _isLoading ? null : _register(),
            validator: Validators.phone,
          ),

          const SizedBox(height: 26),

          PrimaryButton(
            label: 'Daftar',
            isLoading: _isLoading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENDER FIELD (Disesuaikan dengan gaya CustomTextField)
  // ============================================================
  Widget _genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSub,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSub,
            size: 20,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          decoration: InputDecoration(
            hintText: 'Pilih jenis kelamin',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.wc_rounded,
              size: 20,
              color: AppColors.textSub,
            ),
            filled: true,
            fillColor: AppColors.surface,
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
          ),
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
          ],
          onChanged: _isLoading ? null : (v) => setState(() => _gender = v),
          validator: (v) => v == null ? 'Wajib dipilih.' : null,
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN LINK
  // ============================================================
  Widget _loginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: AppColors.textSub,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.login),
          child: Text(
            'Login',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}