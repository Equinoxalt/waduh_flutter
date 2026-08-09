String formatIndonesianDate(String isoDate) {
  final parts = isoDate.split('-');
  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at", 'Sabtu', 'Minggu'];
  const bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${hariList[date.weekday - 1]}, ${date.day} ${bulanList[date.month - 1]} ${date.year}';
}

String formatIndonesianMonthYear(DateTime date) {
  const bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${bulanList[date.month - 1]} ${date.year}';
}

String buildShareText({required String title, required Map<String, int> data}) {
  final buffer = StringBuffer();
  buffer.writeln('📊 Waduh - Hitung Item');
  buffer.writeln(title);
  buffer.writeln();

  if (data.isEmpty) {
    buffer.write('Belum ada data.');
  } else {
    final sortedEntries = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedEntries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    buffer.write('\nTotal ${data.length} jenis barang');
  }

  return buffer.toString();
}

String formatIndonesianDateTime(String isoDateTime) {
  final date = DateTime.parse(isoDateTime).toLocal();
  const bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${bulanList[date.month - 1]} ${date.year}, $jam:$menit';
}

String formatRupiah(int amount) {
  final str = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return 'Rp$buffer';
}