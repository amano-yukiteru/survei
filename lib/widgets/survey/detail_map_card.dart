import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/survey.dart';

class DetailMapCard extends StatelessWidget {
  final Survey survey;
  const DetailMapCard({super.key, required this.survey});

  bool get _hasCoords => survey.latitude != null && survey.longitude != null;

  // Fungsi buka Google Maps
  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // Fungsi salin koordinat
  Future<void> _copyCoordinates(BuildContext context, double lat, double lng) async {
    final text = '$lat, $lng';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text('Koordinat disalin: $text', style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lokasi Survey', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          
          if (_hasCoords) ...[
            // Peta
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(survey.latitude!, survey.longitude!),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_appl_latihan',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(survey.latitude!, survey.longitude!),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on_rounded, color: AppColors.error, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Kotak Koordinat
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lat: ${survey.latitude}\nLng: ${survey.longitude}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyCoordinates(context, survey.latitude!, survey.longitude!),
                    icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Google Maps
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGoogleMaps(survey.latitude!, survey.longitude!),
                icon: const Icon(Icons.map),
                label: const Text('Buka Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ] else
            Text('Koordinat tidak tersedia', style: GoogleFonts.inter(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}