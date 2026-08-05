import 'dio_client.dart';
import '../models/item_model.dart';

class ItemService {
  Future<String?> addItems(List<ItemModel> items, {String? sessionId}) async {
    final response = await dio.post('/api/items', data: {
      'items': items.map((e) => e.toJson()).toList(),
      if (sessionId != null) 'sessionId': sessionId,
    });
    return response.data['sessionId'] as String?;
  }

  Future<List<ItemTotal>> getSessionTotals(String sessionId) async {
    final response = await dio.get('/api/items/session/$sessionId/totals');
    final List<dynamic> data = response.data;
    return data.map((json) => ItemTotal.fromJson(json)).toList();
  }

  Future<List<ItemTotal>> getTotals({String scope = 'today'}) async {
    final response = await dio.get('/api/items/totals', queryParameters: {'scope': scope});
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