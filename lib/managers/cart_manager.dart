import 'package:flutter/foundation.dart';
import 'haptic_manager.dart';

class AddOn {
  final String id;
  final String name;
  final double price;
  final String imagePath;

  const AddOn({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
  });
}

class FoodItem {
  final String id;
  final String name;
  final String priceString;
  final double price;
  final String imagePath;
  final String description;
  final double rating;
  final String category;
  final List<AddOn> availableAddOns;

  const FoodItem({
    required this.id,
    required this.name,
    required this.priceString,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.rating,
    this.category = 'All',
    this.availableAddOns = const [],
  });
}

const sampleDishes = [
  // Biryani & Rice
  FoodItem(
    id: 'chicken_biryani',
    name: 'Hyderabadi Chicken Biryani',
    priceString: '₹180',
    price: 180.0,
    imagePath: 'assets/images/chicken-biryani.png',
    description: 'Aromatic basmati rice cooked with tender marinated chicken, saffron & authentic spices.',
    rating: 4.9,
    category: 'Biriyani',
  ),
  FoodItem(
    id: 'mutton_biryani',
    name: 'Royal Lucknowi Mutton Biryani',
    priceString: '₹280',
    price: 280.0,
    imagePath: 'assets/images/chicken-biryani.png',
    description: 'Slow-cooked succulent mutton dum biryani layered with caramelized onions & fresh mint.',
    rating: 4.9,
    category: 'Biriyani',
  ),
  FoodItem(
    id: 'paneer_biryani',
    name: 'Special Paneer Tikka Biryani',
    priceString: '₹190',
    price: 190.0,
    imagePath: 'assets/images/chicken-biryani.png',
    description: 'Charcoal-grilled paneer cubes tossed in fragrant basmati rice & aromatic spices.',
    rating: 4.7,
    category: 'Biriyani',
  ),
  FoodItem(
    id: 'prawns_biryani',
    name: 'Malabar Spiced Prawn Biryani',
    priceString: '₹260',
    price: 260.0,
    imagePath: 'assets/images/chicken-biryani.png',
    description: 'Fresh coastal prawns simmered in coconut gravy and dum-cooked rice.',
    rating: 4.8,
    category: 'Biriyani',
  ),

  // Burgers
  FoodItem(
    id: 'beef_burger',
    name: 'Classic Angus Beef Burger',
    priceString: '₹199',
    price: 199.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Juicy Angus beef patty topped with melted cheddar, crisp lettuce & house special sauce.',
    rating: 4.9,
    category: 'Burgers',
  ),
  FoodItem(
    id: 'crispy_chicken_burger',
    name: 'Spicy Zinger Chicken Burger',
    priceString: '₹169',
    price: 169.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Crispy fried chicken breast, spicy sriracha mayo & tangy pickles on a brioche bun.',
    rating: 4.8,
    category: 'Burgers',
  ),
  FoodItem(
    id: 'smokey_bbq_burger',
    name: 'Smokey Bacon BBQ Burger',
    priceString: '₹229',
    price: 229.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Double beef patty, crispy bacon, smoked gouda & hickory BBQ glaze.',
    rating: 4.9,
    category: 'Burgers',
  ),
  FoodItem(
    id: 'veggie_supreme_burger',
    name: 'Truffle Veggie Burger',
    priceString: '₹149',
    price: 149.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Portobello mushroom & quinoa patty with truffle aioli & fresh avocado.',
    rating: 4.6,
    category: 'Burgers',
  ),

  // Pizza
  FoodItem(
    id: 'margherita_pizza',
    name: 'Neapolitan Margherita Pizza',
    priceString: '₹249',
    price: 249.0,
    imagePath: 'assets/images/pepperoni-pizza.png',
    description: 'Classic stone-baked sourdough pizza with fresh mozzarella, basil & San Marzano tomatoes.',
    rating: 4.8,
    category: 'Pizza',
  ),
  FoodItem(
    id: 'pepperoni_pizza',
    name: 'Double Pepperoni Feast Pizza',
    priceString: '₹349',
    price: 349.0,
    imagePath: 'assets/images/pepperoni-pizza.png',
    description: 'Loaded with crispy beef pepperoni slices, extra mozzarella & garlic chili oil.',
    rating: 4.9,
    category: 'Pizza',
  ),
  FoodItem(
    id: 'bbq_chicken_pizza',
    name: 'Smokey BBQ Chicken Pizza',
    priceString: '₹379',
    price: 379.0,
    imagePath: 'assets/images/pepperoni-pizza.png',
    description: 'Grilled chicken, red onions, cilantro & tangy sweet BBQ base sauce.',
    rating: 4.7,
    category: 'Pizza',
  ),
  FoodItem(
    id: 'truffle_mushroom_pizza',
    name: 'Wild Truffle Mushroom Pizza',
    priceString: '₹359',
    price: 359.0,
    imagePath: 'assets/images/pepperoni-pizza.png',
    description: 'Sauteed wild mushrooms, white truffle oil, fontina cheese & thyme.',
    rating: 4.9,
    category: 'Pizza',
  ),

  // Noodles
  FoodItem(
    id: 'chicken_ramen',
    name: 'Tonkotsu Chicken Ramen',
    priceString: '₹199',
    price: 199.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Rich savory broth with fresh ramen noodles, grilled chicken, soft-boiled egg & nori.',
    rating: 4.9,
    category: 'Noodles',
  ),
  FoodItem(
    id: 'pad_thai_noodle',
    name: 'Bangkok Street Pad Thai',
    priceString: '₹179',
    price: 179.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Stir-fried rice noodles with tamarind sauce, peanuts, bean sprouts & fresh lime.',
    rating: 4.8,
    category: 'Noodles',
  ),

  // Dessert
  FoodItem(
    id: 'chocolate_cake',
    name: 'Belgian Chocolate Lava Cake',
    priceString: '₹129',
    price: 129.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Rich dark chocolate cake with a warm molten lava center served with vanilla bean ice cream.',
    rating: 4.9,
    category: 'Dessert',
  ),
  FoodItem(
    id: 'classic_tiramisu',
    name: 'Authentic Italian Tiramisu',
    priceString: '₹149',
    price: 149.0,
    imagePath: 'assets/images/hamburger-chips.png',
    description: 'Espresso-soaked ladyfingers layered with whipped mascarpone & cocoa powder.',
    rating: 4.9,
    category: 'Dessert',
  ),

  // Drinks
  FoodItem(
    id: 'iced_matcha',
    name: 'Ceremonial Iced Matcha Latte',
    priceString: '₹99',
    price: 99.0,
    imagePath: 'assets/images/mojito-cocktail.png',
    description: 'Premium Japanese matcha green tea whisked with oat milk & crushed ice.',
    rating: 4.7,
    category: 'Drink',
  ),
  FoodItem(
    id: 'fresh_mojito',
    name: 'Minty Cuban Lime Mojito',
    priceString: '₹80',
    price: 80.0,
    imagePath: 'assets/images/mojito-cocktail.png',
    description: 'Refreshing sparkling cooler with muddled fresh mint leaves, lime juice & cane sugar.',
    rating: 4.8,
    category: 'Drink',
  ),
  FoodItem(
    id: 'mango_lassi',
    name: 'Alphonso Mango Lassi',
    priceString: '₹60',
    price: 60.0,
    imagePath: 'assets/images/mojito-cocktail.png',
    description: 'Chilled sweet yogurt smoothie blended with ripe Alphonso mango pulp.',
    rating: 4.9,
    category: 'Drink',
  ),
];

class CartItem {
  final FoodItem foodItem;
  int quantity;
  final List<AddOn> selectedAddOns;

  CartItem({
    required this.foodItem,
    required this.quantity,
    this.selectedAddOns = const [],
  });

  double get totalPrice {
    double addOnsPrice = selectedAddOns.fold(0.0, (sum, addon) => sum + addon.price);
    return (foodItem.price + addOnsPrice) * quantity;
  }
}

class CartManager extends ValueNotifier<List<CartItem>> {
  static final CartManager instance = CartManager._internal();
  factory CartManager() => instance;

  CartManager._internal() : super([]);

  List<CartItem> get items => List.unmodifiable(value);

  int get totalItemCount => value.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => value.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get subtotal => totalPrice;

  void addItem(FoodItem foodItem, {int quantity = 1, List<AddOn> selectedAddOns = const []}) {
    HapticManager.instance.lightImpact();
    final list = List<CartItem>.from(value);
    final index = list.indexWhere((item) => item.foodItem.name == foodItem.name);
    if (index >= 0) {
      list[index].quantity += quantity;
    } else {
      list.add(CartItem(foodItem: foodItem, quantity: quantity, selectedAddOns: selectedAddOns));
    }
    value = list;
  }

  void updateQuantity(int index, int newQuantity) {
    final list = List<CartItem>.from(value);
    if (index >= 0 && index < list.length) {
      if (newQuantity <= 0) {
        list.removeAt(index);
      } else {
        list[index].quantity = newQuantity;
      }
      value = list;
    }
  }

  int getItemQuantity(String foodItemIdOrName) {
    final index = value.indexWhere((item) => item.foodItem.id == foodItemIdOrName || item.foodItem.name == foodItemIdOrName);
    if (index >= 0) {
      return value[index].quantity;
    }
    return 0;
  }

  void incrementQuantity(FoodItem foodItem) {
    addItem(foodItem, quantity: 1);
  }

  void decrementQuantity(FoodItem foodItem) {
    final list = List<CartItem>.from(value);
    final index = list.indexWhere((item) => item.foodItem.id == foodItem.id || item.foodItem.name == foodItem.name);
    if (index >= 0) {
      if (list[index].quantity > 1) {
        list[index].quantity -= 1;
      } else {
        list.removeAt(index);
      }
      value = list;
    }
  }

  void removeItem(int index) {
    final list = List<CartItem>.from(value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      value = list;
    }
  }

  void clearCart() {
    value = [];
  }
}
