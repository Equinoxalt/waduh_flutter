class ItemModel {
  final String name;
  final int quantity;

  ItemModel({required this.name, required this.quantity});

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};
}

class ItemTotal {
  final String name;
  final int total;

  ItemTotal({required this.name, required this.total});

  factory ItemTotal.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'];
    final total = rawTotal is String ? int.parse(rawTotal) : (rawTotal as num).toInt();
    return ItemTotal(name: json['name'] as String, total: total);
  }
}

class DailyHistoryEntry {
  final String date;
  final String name;
  final int total;

  DailyHistoryEntry({required this.date, required this.name, required this.total});

  factory DailyHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'];
    final total = rawTotal is String ? int.parse(rawTotal) : (rawTotal as num).toInt();
    return DailyHistoryEntry(
      date: json['date'] as String,
      name: json['name'] as String,
      total: total,
    );
  }
}