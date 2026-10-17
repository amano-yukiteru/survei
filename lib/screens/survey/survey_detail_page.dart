import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/survey.dart';
import '../../routes/app_routes.dart';
import '../../services/survey_service.dart';
import '../../widgets/survey/detail_photo_card.dart';
import '../../widgets/survey/detail_map_card.dart';

class SurveyDetailPage extends StatefulWidget {
  final int surveyId;

  const SurveyDetailPage({super.key, required this.surveyId});

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  Survey? _survey;
  Future<Uint8List?>? _imageFuture;

  bool _isLoading = true;
  bool _isNotFound = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================
  // 1. AMBIL DATA DARI API SERVICE
  // ==========================================
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNotFound = false;
    });

    try {
      final data = await SurveyService.getSurveyDetail(widget.surveyId);

      Future<Uint8List?>? imgFuture;
      if (data.photo != null && data.photo!.isNotEmpty) {
        imgFuture = SurveyService.getImage(data.photo!);
      }

      if (!mounted) return;
      setState(() {
        _survey = data;
        _imageFuture = imgFuture;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');

      if (msg == 'UNAUTHORIZED') {
        context.go(AppRoutes.login);
      } else if (msg == 'NOT_FOUND') {
        setState(() {
          _isNotFound = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // 2. HAPUS SURVEY
  // ==========================================
  Future<void> _deleteSurvey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Hapus Survey',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus survey ini? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppColors.textSub),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SurveyService.deleteSurvey(widget.surveyId);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Survey berhasil dihapus')));
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  // ==========================================
  // 3. EDIT SURVEY
  // ==========================================
  Future<void> _editSurvey() async {
    if (_survey == null) return;

    final result = await context.push(AppRoutes.editSurvey, extra: _survey);
    if (result == true && mounted) {
      _loadData();
    }
  }

  // ==========================================
  // 4. BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppHeader(pageTitle: 'Detail Survei'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_isNotFound) {
      return const Center(child: Text('Data survey tidak ditemukan.'));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSub),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final survey = _survey!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        final leftContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(survey),
            const SizedBox(height: 16),
            DetailPhotoCard(imageFuture: _imageFuture, title: survey.title),
          ],
        );

        final rightContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [DetailMapCard(survey: survey)],
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: leftContent),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: rightContent),
                      ],
                    )
                  : Column(
                      children: [
                        leftContent,
                        const SizedBox(height: 16),
                        rightContent,
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // Card Info Utama (Judul, Kategori, Deskripsi) + TOMBOL EDIT & HAPUS
  Widget _buildHeaderCard(Survey survey) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Kategori, ID, dan Tombol Aksi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  survey.categoryName,
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${survey.id}',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),

              // ✅ TOMBOL EDIT DAN HAPUS DI SINI
              const SizedBox(width: 8),
              InkWell(
                onTap: _editSurvey,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _deleteSurvey,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            survey.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Deskripsi:',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            survey.description,
            style: GoogleFonts.inter(color: AppColors.textSub, height: 1.5),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                survey.formattedDate,
                style: GoogleFonts.inter(
                  color: AppColors.textSub,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
