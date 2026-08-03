import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiwayatController>().loadHistory();
    });
  }

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at", 'Sabtu', 'Minggu'];
    const bulanList = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    return '${hariList[date.weekday - 1]}, ${date.day} ${bulanList[date.month - 1]} ${date.year}';
  }

  Future<void> _confirmDelete(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus riwayat ini?'),
        content: Text('Semua data pada ${_formatDate(date)} akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<RiwayatController>().deleteDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RiwayatController>();
    final dates = controller.groupedHistory.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dates.isEmpty
          ? const Center(child: Text('Belum ada riwayat'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final items = controller.groupedHistory[date]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(date), style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Hapus tanggal ini',
                      onPressed: () => _confirmDelete(date),
                    ),
                  ],
                ),
                ...items.map((item) => Card(
                  margin: const EdgeInsets.only(top: 6),
                  child: ListTile(
                    title: Text(item.name),
                    trailing: Text('${item.total}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}