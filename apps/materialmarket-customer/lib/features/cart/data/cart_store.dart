import 'package:flutter/foundation.dart';
import '../../catalog/data/catalog_remote_data_source.dart';

class CartItem {
  CartItem(this.product, this.qty);
  final Product product;
  double qty;
}

/// Simple in-memory cart shared via ChangeNotifier.
class CartStore extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Iterable<CartItem> get items => _items.values;
  int get count => _items.length;
  int get total => _items.values.fold(0, (s, it) => s + (it.product.price * it.qty).toInt());

  void add(Product p, [double qty = 1]) {
    final existing = _items[p.id];
    if (existing == null) {
      _items[p.id] = CartItem(p, qty);
    } else {
      existing.qty += qty;
    }
    notifyListeners();
  }

  void setQty(String id, double qty) {
    final it = _items[id];
    if (it == null) return;
    if (qty <= 0) {
      _items.remove(id);
    } else {
      it.qty = qty;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
