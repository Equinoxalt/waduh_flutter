import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class HitungController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool isLoading = false;
  String? errorMessage;
  List<ItemTotal> totals = [];
  List<int> skippedLines = [];

  List<ItemModel> _parseInput(String rawText) {
    final lines = rawText.split('\n');
    final items = <ItemModel>[];
    final skipped = <int>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(':');
      if (parts.length != 2) {
        skipped.add(i + 1);
        continue;
      }

      final name = parts[0].trim();
      final quantity = int.tryParse(parts[1].trim());

      if (name.isEmpty || quantity == null || quantity <= 0) {
        skipped.add(i + 1);
        continue;
      }

      items.add(ItemModel(name: name, quantity: quantity));
    }

    skippedLines = skipped;
    return items;
  }

  // padanan tombol "Hitung"
  Future<void> hitung(String rawText) async {
    final items = _parseInput(rawText);
    errorMessage = null;

    if (items.isEmpty) {
      errorMessage = 'Tidak ada baris valid untuk dihitung';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _itemService.addItems(items);
      totals = await _itemService.getTotals();
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  // padanan tombol "Hapus Hasil"
  Future<void> hapusHasil() async {
    isLoading = true;
    errorMessage = null;
    skippedLines = [];
    notifyListeners();

    try {
      await _itemService.deleteAll();
      totals = await _itemService.getTotals();
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  // dipanggil sekali waktu halaman pertama kali dibuka
  Future<void> loadTotals() async {
    isLoading = true;
    notifyListeners();

    try {
      totals = await _itemService.getTotals();
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }
}