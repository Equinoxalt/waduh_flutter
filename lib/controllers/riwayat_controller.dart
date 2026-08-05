import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class RiwayatController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, List<DailyHistoryEntry>> groupedHistory = {};

  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entries = await _itemService.getHistory();
      final grouped = <String, List<DailyHistoryEntry>>{};
      for (final entry in entries) {
        grouped.putIfAbsent(entry.date, () => []).add(entry);
      }
      groupedHistory = grouped;
    } on DioException {
      errorMessage = 'Gagal terhubung ke server';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDate(String date) async {
    try {
      await _itemService.deleteHistoryByDate(date);
      groupedHistory.remove(date);
      notifyListeners();
    } on DioException {
      errorMessage = 'Gagal menghapus data';
      notifyListeners();
    }
  }

  Future<void> deleteAllHistory() async {
    try {
      await _itemService.deleteAll();
      groupedHistory = {};
      notifyListeners();
    } on DioException {
      errorMessage = 'Gagal menghapus data';
      notifyListeners();
    }
  }

}