class Validators {
  // 1. Validasi Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    // Regex sederhana untuk cek format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null; // Null artinya valid (tidak ada error)
  }

  // 2. Validasi Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // 3. Validasi Wajib Isi (Untuk Nama, Judul, dll)
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  // 4. Validasi Nomor HP/WhatsApp
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Nomor HP tidak valid (10-15 digit)';
    }
    return null;
  }
}