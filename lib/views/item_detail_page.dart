import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/item_detail_controller.dart';
import '../models/item_model.dart';
import '../utils/formatters.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemName;
  final String? sessionId;
  final String? scope;
  final String? date;

  const ItemDetailPage({
    super.key,
    required this.itemName,
    this.sessionId,
    this.scope,
    this.date,
  });

  Future<void> _showEditDialog(BuildContext context, ItemRow row) async {
    final nameController = TextEditingController(text: row.name);
    final quantityController = TextEditingController(text: '${row.quantity}');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final name = nameController.text.trim();
      final quantity = int.tryParse(quantityController.text.trim());
      if (name.isEmpty || quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan jumlah harus diisi dengan benar')),
        );
        return;
      }
      context.read<ItemDetailController>().updateRow(row.id, name, quantity);
    }
  }

  Future<void> _confirmDelete(BuildContext context, ItemRow row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus baris ini?'),
        content: Text('Baris "${row.name}: ${row.quantity}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ItemDetailController>().deleteRow(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailController()
        ..loadRows(name: itemName, sessionId: sessionId, scope: scope, date: date),
      child: Scaffold(
        appBar: AppBar(title: Text(itemName)),
        body: Consumer<ItemDetailController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.rows.isEmpty) {
              return const Center(child: Text('Tidak ada baris ditemukan'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.rows.length,
              itemBuilder: (context, index) {
                final row = controller.rows[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${row.name}: ${row.quantity}'),
                    subtitle: Text(formatIndonesianDateTime(row.createdAt)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit',
                          onPressed: () => _showEditDialog(context, row),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          tooltip: 'Hapus',
                          onPressed: () => _confirmDelete(context, row),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}