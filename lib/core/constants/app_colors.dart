
import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF0F172A);       // Slate 900 (Navy Gelap)
  static const Color accent = Color(0xFF0EA5E9);        // Sky 500 (Biru Muda)
  
  static const Color bg = Color(0xFFF8FAFC);            // Slate 50 (Background aplikasi)
  static const Color surface = Colors.white;            // Putih (Untuk Card/Container)
  
  static const Color text = Color(0xFF0F172A);          // Teks Utama
  static const Color textSub = Color(0xFF475569);       // Teks Sekunder (Abu-abu gelap)
  static const Color textMuted = Color(0xFF94A3B8);     // Teks Pudar (Placeholder)
  
  static const Color border = Color(0xFFE2E8F0);        // Garis Batas / Divider
  static const Color error = Color(0xFFDC2626);         // Merah (Pesan Error)
  static const Color success = Color(0xFF16A34A);       // Hijau (Pesan Sukses)
}