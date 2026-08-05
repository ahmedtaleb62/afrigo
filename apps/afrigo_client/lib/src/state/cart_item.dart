class CartItem {
  const CartItem({required this.dishId, required this.name, required this.price, required this.qty});

  final String dishId;
  final String name;
  final int price;
  final int qty;

  CartItem copyWith({int? qty}) => CartItem(dishId: dishId, name: name, price: price, qty: qty ?? this.qty);
}
