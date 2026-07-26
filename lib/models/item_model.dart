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