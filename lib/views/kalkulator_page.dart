import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/hitung_controller.dart' show TotalScope;
import '../controllers/kalkulator_controller.dart';
import '../utils/formatters.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KalkulatorController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KalkulatorController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TotalScope>(
              segments: const [
                ButtonSegment(value: TotalScope.today, label: Text('Hari Ini')),
                ButtonSegment(value: TotalScope.month, label: Text('Bulan Ini')),
                ButtonSegment(value: TotalScope.all, label: Text('Semua')),
              ],
              selected: {controller.scope},
              onSelectionChanged: (selected) => controller.changeScope(selected.first),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pendapatan',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(controller.grandTotal),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (controller.isLoading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: controller.totals.isEmpty
                  ? const Center(child: Text('Belum ada data untuk dihitung'))
                  : ListView.builder(
                itemCount: controller.totals.length,
                itemBuilder: (context, index) {
                  final item = controller.totals[index];
                  final price = controller.prices[item.name] ?? 0;
                  return _PriceRow(
                    key: ValueKey(item.name),
                    name: item.name,
                    quantity: item.total,
                    price: price,
                    onPriceChanged: (newPrice) => controller.updatePrice(item.name, newPrice),
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

class _PriceRow extends StatefulWidget {
  final String name;
  final int quantity;
  final int price;
  final ValueChanged<int> onPriceChanged;

  const _PriceRow({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.onPriceChanged,
  });

  @override
  State<_PriceRow> createState() => _PriceRowState();
}

class _PriceRowState extends State<_PriceRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price == 0 ? '' : '${widget.price}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed != null && parsed >= 0 && parsed != widget.price) {
      widget.onPriceChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.quantity * widget.price;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${widget.quantity} unit', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga satuan',
                      prefixText: 'Rp ',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatRupiah(subtotal),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}