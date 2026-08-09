import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
import 'hitung_controller.dart' show TotalScope;

class KalkulatorController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool isLoading = false;
  String? errorMessage;
  List<ItemTotal> totals = [];
  Map<String, int> prices = {};
  TotalScope scope = TotalScope.today;

  String get _scopeParam {
    switch (scope) {
      case TotalScope.today:
        return 'today';
      case TotalScope.month:
        return 'month';
      case TotalScope.all:
        return 'all';
    }
  }

  int get grandTotal {
    var sum = 0;
    for (final item in totals) {
      sum += item.total * (prices[item.name] ?? 0);
    }
    return sum;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _itemService.getTotals(scope: _scopeParam),
        _itemService.getPrices(),
      ]);
      totals = results[0] as List<ItemTotal>;
      final priceList = results[1] as List<ItemPrice>;
      prices = {for (final p in priceList) p.name: p.price};
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> changeScope(TotalScope newScope) async {
    if (scope == newScope) return;
    scope = newScope;
    isLoading = true;
    notifyListeners();

    try {
      totals = await _itemService.getTotals(scope: _scopeParam);
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePrice(String name, int price) async {
    prices[name] = price; // update lokal dulu, biar total langsung berubah
    notifyListeners();

    try {
      await _itemService.setPrice(name, price);
    } on DioException {
      errorMessage = 'Gagal menyimpan harga';
      notifyListeners();
    }
  }
}