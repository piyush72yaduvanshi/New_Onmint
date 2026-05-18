import 'package:flutter/foundation.dart';

class CartItem {
  final String medicineId;
  final String name;
  final double price;
  int quantity;
  final String? imageUrl;
  
  CartItem({
    required this.medicineId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });
  
  double get totalPrice => price * quantity;
}

class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();
  
  final Map<String, CartItem> _items = {};
  
  Map<String, CartItem> get items => {..._items};
  
  int get itemCount => _items.length;
  
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }
  
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }
  
  void addItem(String medicineId, String name, double price, String? imageUrl) {
    if (_items.containsKey(medicineId)) {
      _items.update(
        medicineId,
        (existing) => CartItem(
          medicineId: existing.medicineId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        medicineId,
        () => CartItem(
          medicineId: medicineId,
          name: name,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }
  
  void removeItem(String medicineId) {
    _items.remove(medicineId);
    notifyListeners();
  }
  
  void updateQuantity(String medicineId, int quantity) {
    if (_items.containsKey(medicineId)) {
      if (quantity <= 0) {
        _items.remove(medicineId);
      } else {
        _items.update(
          medicineId,
          (existing) => CartItem(
            medicineId: existing.medicineId,
            name: existing.name,
            price: existing.price,
            quantity: quantity,
            imageUrl: existing.imageUrl,
          ),
        );
      }
      notifyListeners();
    }
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getOrderItems() {
    return _items.values.map((item) => {
      'medicine': item.medicineId,
      'quantity': item.quantity,
      'price': item.price,
    }).toList();
  }
}
