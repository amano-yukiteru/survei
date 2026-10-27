import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../core/constants/app_colors.dart';
import '../../models/survey.dart';
import '../../services/survey_service.dart';
import '../../widgets/survey_form/form_image_picker.dart';
import '../../widgets/survey_form/form_map_picker.dart';

class SurveyFormPage extends StatefulWidget {
  final Survey? survey;
  const SurveyFormPage({super.key, this.survey});

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _mapController = MapController();

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  LatLng? _selectedLocation;
  
  Uint8List? _imageBytes;
  String? _imageName;
  Future<Uint8List?>? _existingImageFuture;

  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get isEdit => widget.survey != null;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  Future<void> _initForm() async {
    if (isEdit) {
      _titleCtrl.text = widget.survey!.title;
      _descCtrl.text = widget.survey!.description == '-' ? '' : widget.survey!.description;
      _selectedCategoryId = widget.survey!.categoryId.toString();
      
      if (widget.survey!.latitude != null && widget.survey!.longitude != null) {
        _latCtrl.text = widget.survey!.latitude.toString();
        _lngCtrl.text = widget.survey!.longitude.toString();
        _selectedLocation = LatLng(widget.survey!.latitude!, widget.survey!.longitude!);
      }

      if (widget.survey!.photo != null && widget.survey!.photo!.isNotEmpty) {
        // Token sudah diurus otomatis oleh SurveyService (ApiService)
        _existingImageFuture = SurveyService.getImage(widget.survey!.photo!);
      }
    }

    // Listener agar jika user ngetik koordinat, peta ikut bergeser
    _latCtrl.addListener(_onCoordinateTyped);
    _lngCtrl.addListener(_onCoordinateTyped);

    await _loadCategories();
  }

  void _onCoordinateTyped() {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat != null && lng != null) {
      setState(() => _selectedLocation = LatLng(lat, lng));
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Token sudah diurus otomatis
      final data = await SurveyService.getCategories();
      if (!mounted) return; // Cek mounted sebelum setState
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Cek mounted sebelum memunculkan snackbar
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat kategori')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1000, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }

    setState(() => _isSubmitting = true);

    final fields = {
      'title': _titleCtrl.text.trim(),
      'category_id': _selectedCategoryId!,
      'description': _descCtrl.text.trim(),
      'latitude': _latCtrl.text.trim(),
      'longitude': _lngCtrl.text.trim(),
    };

    if (isEdit) {
      fields['id'] = widget.survey!.id.toString();
      fields['_method'] = 'PUT'; // Untuk Laravel/API edit
    }

    try {
      // Token sudah diurus otomatis
      await SurveyService.saveSurvey(
        fields: fields,
        imageBytes: _imageBytes,
        imageName: _imageName,
      );

      if (!mounted) return;
      context.pop(true); // Kembali dan trigger refresh
    } catch (e) {
      if (!mounted) return; // Cek mounted sebelum memunculkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        pageTitle: isEdit ? 'Edit Survey' : 'Tambah Survey',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // CARD 1: Data Utama
                    _buildCard(
                      title: 'Data Utama',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(labelText: 'Judul Survey', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownSearch<String>(
                            selectedItem: _categories
                                .where((c) => c['id'].toString() == _selectedCategoryId)
                                .map((c) => c['name'].toString())
                                .isEmpty
                                ? null
                                : _categories
                                    .firstWhere(
                                      (c) => c['id'].toString() == _selectedCategoryId,
                                    )['name']
                                    .toString(),
                            items: (filter, infiniteScrollProps) {
                              return _categories
                                  .where((c) => c['name']
                                      .toString()
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()))
                                  .take(10)
                                  .map((c) => c['name'].toString())
                                  .toList();
                            },
                            onSelected: (v) {
                              setState(() {
                                _selectedCategoryId = v == null
                                    ? null
                                    : _categories
                                        .firstWhere((c) => c['name'].toString() == v)['id']
                                        .toString();
                              });
                            },
                            decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: 'Cari kategori...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 2: Foto
                    _buildCard(
                      title: 'Foto Survey',
                      child: FormImagePicker(
                        imageBytes: _imageBytes,
                        existingImageFuture: _existingImageFuture,
                        isEdit: isEdit,
                        onPick: _pickImage,
                        onRemove: () => setState(() { _imageBytes = null; _imageName = null; }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 3: Peta
                    _buildCard(
                      title: 'Lokasi Survey',
                      child: FormMapPicker(
                        mapController: _mapController,
                        selectedLocation: _selectedLocation,
                        latController: _latCtrl,
                        lngController: _lngCtrl,
                        isValidCoordinate: true,
                        onLocationChanged: (point) {
                          setState(() {
                            _selectedLocation = point;
                            _latCtrl.text = point.latitude.toStringAsFixed(7);
                            _lngCtrl.text = point.longitude.toStringAsFixed(7);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Survey', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}