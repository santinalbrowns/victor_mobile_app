import 'package:flutter_tag/shared/models/product.dart';

class Item {
  final String sku;
  int quantity;
  final double price;

  final Product product;

  Item(
      {required this.sku,
      required this.quantity,
      required this.price,
      required this.product});

  Map<String, dynamic> toJson() {
    return {
      "sku": sku,
      "quantity": quantity,
      "price": price,
    };
  }
}

class Cart {
  final int storeId;
  final List<Item> items;

  Cart({required this.storeId, required this.items});

  Map<String, dynamic> toJson() {
    return {
      "store_id": storeId,
      "items": items.map((item) => item.toJson()).toList(),
    };
  }
}
