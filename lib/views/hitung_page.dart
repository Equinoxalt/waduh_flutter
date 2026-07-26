import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/hitung_controller.dart';

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
      appBar: AppBar(title: const Text('Hitung Item')),
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
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(controller.errorMessage!, style: const TextStyle(color: Colors.red)),
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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isLoading ? null : controller.hapusHasil,
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