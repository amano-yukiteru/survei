import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart'; // <-- Import tema warna
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman Login setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Putih bersih dari tema
      body: Stack(
        children: [
          // Konten Utama (Tengah Layar)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo minimalis
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Navy
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Judul
                Text(
                  'FIELD SURVEY',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Aplikasi Survei Berbasis Lokasi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSub, // Warna abu-abu dari tema
                  ),
                ),
                Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent), // Sky Blue
                ),
              ),
            ),
          ),
              ],
              
            ),
            
          ),

          // Loading Indicator di bagian bawah
          
        ],
      ),
    );
  }
}