import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/hitung_controller.dart';
import 'package:waduh/views/riwayat_page.dart';

class HitungPage extends StatefulWidget {
  const HitungPage({super.key});

  @override
  State<HitungPage> createState() => _HitungPageState();
}

class _HitungPageState extends State<HitungPage> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HitungController>().loadTotals();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HitungController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Masukkan data',
                hintText: 'contoh: Blanket : 20',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (controller.skippedLines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Baris ${controller.skippedLines.join(", ")} dilewati (format salah)',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                      controller.hitung(_inputController.text);
                      _inputController.clear();
                    },
                    child: const Text('Hitung'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RiwayatPage()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  tooltip: 'Riwayat',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus semua data?'),
                          content: const Text(
                            'Ini akan menghapus SEMUA data, termasuk seluruh riwayat hari-hari sebelumnya. Tindakan ini tidak bisa dibatalkan.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus Semua')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        controller.hapusHasil();
                      }
                    },
                    child: const Text('Hapus Hasil'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.isLoading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: controller.totals.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                itemCount: controller.totals.length,
                itemBuilder: (context, index) {
                  final item = controller.totals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.name),
                      trailing: Text(
                        '${item.total}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}