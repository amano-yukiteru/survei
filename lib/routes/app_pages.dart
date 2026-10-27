import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// IMPORT HALAMAN (Gunakan package: agar tidak pusing path)
import 'package:flutter_appl_latihan/models/survey.dart';
import 'package:flutter_appl_latihan/routes/app_routes.dart';
import 'package:flutter_appl_latihan/screens/dashboard/dashboard.dart';
import 'package:flutter_appl_latihan/screens/profile/edit_profile.dart';
import 'package:flutter_appl_latihan/screens/auth/login_page.dart';
import 'package:flutter_appl_latihan/screens/auth/register_page.dart';
import 'package:flutter_appl_latihan/screens/splash/splash_screen.dart';
import 'package:flutter_appl_latihan/screens/survey/survey_detail_page.dart';
import 'package:flutter_appl_latihan/screens/survey/survey_form_page.dart';

class AppPages {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Auth (Login & Register)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // 3. Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Dashboard(),
      ),

      // 4. Edit Profile
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          // Menerima data profil yang dikirim dari halaman Profile
          final profile = state.extra as Map<String, dynamic>?;
          return EditProfilePage(profile: profile);
        },
      ),

      // 5. Tambah Survey
      GoRoute(
        path: AppRoutes.addSurvey,
        builder: (context, state) => const SurveyFormPage(),
      ),

      // 6. Edit Survey
      GoRoute(
        path: AppRoutes.editSurvey,
        builder: (context, state) {
          final survey = state.extra as Survey?;
          return SurveyFormPage(survey: survey);
        },
      ),

      // 7. Detail Survey
      GoRoute(
        path: AppRoutes.surveyDetail,
        builder: (context, state) {
          // Menyederhanakan: Asumsikan yang dikirim dari halaman Daftar Survey adalah Integer (ID)
          final id = state.extra as int? ?? 0;
          return SurveyDetailPage(surveyId: id);
        },
      ),
    ],
  );
}