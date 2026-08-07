import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/riwayat_controller.dart';
import '../models/item_model.dart';
import '../utils/formatters.dart';

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

  Future<void> _confirmDelete(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus riwayat ini?'),
        content: Text('Semua data pada ${formatIndonesianDate(date)} akan dihapus permanen.'),
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

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus seluruh riwayat?'),
        content: const Text(
          'Semua data dari semua tanggal akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus Semua')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<RiwayatController>().deleteAllHistory();
    }
  }

  void _shareDate(String date, List<DailyHistoryEntry> items) {
    final data = {for (final item in items) item.name: item.total};
    SharePlus.instance.share(
      ShareParams(text: buildShareText(title: formatIndonesianDate(date), data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RiwayatController>();
    final dates = controller.groupedHistory.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: 'Hapus semua riwayat',
            onPressed: dates.isEmpty ? null : _confirmDeleteAll,
          ),
        ],
      ),
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
                  children: [
                    Expanded(
                      child: Text(formatIndonesianDate(date), style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Bagikan',
                      onPressed: () => _shareDate(date, items),
                    ),
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