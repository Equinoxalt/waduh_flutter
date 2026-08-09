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

class ItemRow {
  final int id;
  final String name;
  final int quantity;
  final String createdAt;

  ItemRow({required this.id, required this.name, required this.quantity, required this.createdAt});

  factory ItemRow.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final quantity = rawQuantity is String ? int.parse(rawQuantity) : (rawQuantity as num).toInt();
    return ItemRow(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: quantity,
      createdAt: json['created_at'] as String,
    );
  }
}

class ItemPrice {
  final String name;
  final int price;

  ItemPrice({required this.name, required this.price});

  factory ItemPrice.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final price = rawPrice is String ? int.parse(rawPrice) : (rawPrice as num).toInt();
    return ItemPrice(name: json['name'] as String, price: price);
  }
}