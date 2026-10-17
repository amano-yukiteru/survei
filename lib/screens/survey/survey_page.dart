import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/survey.dart';
import '../../routes/app_routes.dart';
import '../../services/survey_service.dart';
import '../../widgets/survey/survey_card.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Survey> _surveys = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

  // ==========================================
  // 1. AMBIL DATA DARI SERVICE API
  // ==========================================
  Future<void> _fetchSurveys() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Panggil fungsi dari SurveyService (Token sudah otomatis)
      final data = await SurveyService.getSurveys();

      if (!mounted) return;
      setState(() {
        _surveys = data;
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
  // 2. NAVIGASI KE DETAIL & TAMBAH
  // ==========================================
  Future<void> _openDetail(int id) async {
    final result = await context.push(AppRoutes.surveyDetail, extra: id);
    if (result == true && mounted) {
      _fetchSurveys(); // Refresh list jika ada perubahan
    }
  }

  Future<void> _openAddSurvey() async {
    final result = await context.push(AppRoutes.addSurvey);
    if (result == true && mounted) {
      _fetchSurveys(); // Refresh list jika berhasil tambah data
    }
  }

  // ==========================================
  // 3. BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // ✅ YANG BENAR:
      appBar: AppHeader(
        pageTitle: 'Survei',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSurvey,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah', 
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchSurveys,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // State 1: Loading
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // State 2: Error
    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSub, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchSurveys,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // State 3: Kosong (Empty)
    if (_surveys.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.folder_open_rounded, 
            size: 72, 
            color: AppColors.textMuted.withValues(alpha: 0.5)
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data survey.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSub, 
              fontSize: 14, 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      );
    }

    // State 4: Sukses (Tampil Data)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), 
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 145, // Tinggi tetap untuk setiap Card
          ),
          itemCount: _surveys.length,
          itemBuilder: (context, index) {
            final survey = _surveys[index];
            return SurveyCard(
              survey: survey,
              onTap: () => _openDetail(survey.id),
            );
          },
        );
      },
    );
  }
}