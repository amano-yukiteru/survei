import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/survey.dart';
import '../../routes/app_routes.dart';
import '../../services/survey_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/app_header.dart'; // <-- Cukup panggil ini
import '../../widgets/home/stat_card.dart';
import '../../widgets/home/home_survey_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<Survey> _surveys = [];
  int _totalCategory = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // HANYA mengambil data SURVEY (Profil sudah diurus AppHeader)
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final surveyData = await SurveyService.getSurveys();

      // Hitung total kategori unik
      Set<String> categories = {};
      for (var item in surveyData) {
        categories.add(item.categoryName);
      }

      if (!mounted) return;
      setState(() {
        _surveys = surveyData;
        _totalCategory = categories.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (e.toString().contains('UNAUTHORIZED')) {
        context.go(AppRoutes.login);
      } else {
        SnackbarHelper.show(context, 'Gagal memuat data: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      
      // MENGGUNAKAN WIDGET APP HEADER
      // Nama dan Foto akan otomatis muncul dari API!
      appBar: const AppHeader(
        pageTitle: 'Beranda',
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addSurvey),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: _surveys.length.toString(),
                            title: 'Total Survey',
                            icon: Icons.assignment_outlined,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: StatCard(
                            value: _totalCategory.toString(),
                            title: 'Total Kategori',
                            icon: Icons.category_outlined,
                            iconColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Survey Terbaru',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                    const SizedBox(height: 16),
                    _surveys.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _surveys.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final survey = _surveys[index];
                              return HomeSurveyItem(
                                survey: survey,
                                onTap: () => context.push(AppRoutes.surveyDetail, extra: survey.id),
                              );
                            },
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Belum ada data survey.', style: GoogleFonts.inter(color: AppColors.textSub, fontSize: 13)),
        ],
      ),
    );
  }
}