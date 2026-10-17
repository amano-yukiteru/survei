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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIC API LOGIN (MENGGUNAKAN AUTH SERVICE)
  // ============================================================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Panggil AuthService (Token & User otomatis disimpan)
      await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      
      SnackbarHelper.show(context, 'Login berhasil! Mengalihkan...');
      context.go(AppRoutes.dashboard);

    } catch (e) {
      if (!mounted) return;
      
      // Tampilkan pesan error dari server atau jaringan
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
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'FIELD SURVEY',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masuk untuk melanjutkan',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSub,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CustomTextField 1 (Email)
          CustomTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.alternate_email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            validator: Validators.email, // Memakai validator dari utils
          ),
          const SizedBox(height: 20),
          
          // CustomTextField 2 (Password)
          CustomTextField(
            label: 'Password',
            hint: 'Masukkan password',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            validator: Validators.password, // Memakai validator dari utils
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 32),
          
          // Tombol Login
          PrimaryButton(
            label: 'Masuk',
            isLoading: _isLoading,
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSub),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.register),
          child: Text(
            'Daftar',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}