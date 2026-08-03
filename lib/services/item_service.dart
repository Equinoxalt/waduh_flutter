import 'dio_client.dart';
import '../models/item_model.dart';

class ItemService {
  Future<void> addItems(List<ItemModel> items) async {
    await dio.post('/api/items', data: {
      'items': items.map((e) => e.toJson()).toList(),
    });
  }

  Future<List<ItemTotal>> getTotals() async {
    final response = await dio.get('/api/items/totals');
    final List<dynamic> data = response.data;
    return data.map((json) => ItemTotal.fromJson(json)).toList();
  }

  Future<void> deleteAll() async {
    await dio.delete('/api/items');
  }

  Future<List<DailyHistoryEntry>> getHistory() async {
    final response = await dio.get('/api/items/history');
    final List<dynamic> data = response.data;
    return data.map((json) => DailyHistoryEntry.fromJson(json)).toList();
  }

  Future<void> deleteHistoryByDate(String date) async {
    await dio.delete('/api/items/history/$date');
  }

}