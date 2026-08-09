import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemDetailController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool isLoading = false;
  String? errorMessage;
  List<ItemRow> rows = [];

  Future<void> loadRows({required String name, String? sessionId, String? scope, String? date}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      rows = await _itemService.getItemRows(name: name, sessionId: sessionId, scope: scope, date: date);
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateRow(int id, String name, int quantity) async {
    try {
      await _itemService.updateItem(id, name, quantity);
      final index = rows.indexWhere((r) => r.id == id);
      if (index != -1) {
        rows[index] = ItemRow(id: id, name: name, quantity: quantity, createdAt: rows[index].createdAt);
      }
      notifyListeners();
    } on DioException {
      errorMessage = 'Gagal memperbarui item';
      notifyListeners();
    }
  }

  Future<void> deleteRow(int id) async {
    try {
      await _itemService.deleteItem(id);
      rows.removeWhere((r) => r.id == id);
      notifyListeners();
    } on DioException {
      errorMessage = 'Gagal menghapus item';
      notifyListeners();
    }
  }
}