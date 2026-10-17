class Formatters {
  // 1. Format Tanggal ke Bahasa Indonesia (Contoh: 18 Okt 2026)
  static String dateIndo(String? dateString, {bool withTime = false}) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString.replaceFirst(' ', 'T'));
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      
      final day = date.day.toString();
      final month = months[date.month - 1];
      final year = date.year.toString();
      
      if (withTime) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return '$day $month $year, $hour:$minute';
      }
      
      return '$day $month $year';
    } catch (e) {
      return dateString; // Jika gagal, kembalikan teks aslinya
    }
  }

  // 2. Format Koordinat (Contoh: -7.3274, 108.2207)
  static String coordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Lokasi tidak tersedia';
    return '$lat, $lng';
  }

  // 3. Batasi Panjang Teks (Contoh untuk Deskripsi di Card)
  static String truncate(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '-';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}