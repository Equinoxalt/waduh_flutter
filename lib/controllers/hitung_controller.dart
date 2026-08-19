import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

enum TotalScope { today, month, all }

class HitungController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool isLoading = false;
  String? errorMessage;
  List<ItemTotal> totals = [];
  List<ItemTotal> sessionTotals = [];
  List<int> skippedLines = [];
  String? currentSessionId;
  TotalScope scope = TotalScope.today;

  String get scopeParam {
    switch (scope) {
      case TotalScope.today:
        return 'today';
      case TotalScope.month:
        return 'month';
      case TotalScope.all:
        return 'all';
    }
  }

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
      final returnedSessionId = await _itemService.addItems(items, sessionId: currentSessionId);
      if (returnedSessionId != null) {
        currentSessionId = returnedSessionId;
        sessionTotals = await _itemService.getSessionTotals(currentSessionId!);
      }
      totals = await _itemService.getTotals(scope: scopeParam);
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  void hapusHasil() {
    currentSessionId = null;
    sessionTotals = [];
    skippedLines = [];
    notifyListeners();
  }

  Future<void> changeScope(TotalScope newScope) async {
    if (scope == newScope) return;
    scope = newScope;
    notifyListeners();
    await loadTotals();
  }

  Future<void> loadTotals() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      totals = await _itemService.getTotals(scope: scopeParam);
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  // dipanggil setelah balik dari ItemDetailPage, karena edit/hapus di sana
  // bisa mempengaruhi baik Total Sesi Ini maupun daftar total scope
  Future<void> refreshAfterEdit() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (currentSessionId != null) {
        sessionTotals = await _itemService.getSessionTotals(currentSessionId!);
      }
      totals = await _itemService.getTotals(scope: scopeParam);
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }
}