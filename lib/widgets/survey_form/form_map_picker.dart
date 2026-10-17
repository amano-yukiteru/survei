import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';

class FormMapPicker extends StatelessWidget {
  final MapController mapController;
  final LatLng? selectedLocation;
  final TextEditingController latController;
  final TextEditingController lngController;
  final Function(LatLng) onLocationChanged;
  final bool isValidCoordinate;

  const FormMapPicker({
    super.key,
    required this.mapController,
    required this.selectedLocation,
    required this.latController,
    required this.lngController,
    required this.onLocationChanged,
    required this.isValidCoordinate,
  });

  @override
  Widget build(BuildContext context) {
    // Default center (Tasikmalaya)
    final center = selectedLocation ?? const LatLng(-7.3274, 108.2207);

    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              onTap: (tapPosition, point) => onLocationChanged(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_appl_latihan',
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < -90 || parsed > 90) return 'Tidak valid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: lngController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < -180 || parsed > 180) return 'Tidak valid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}