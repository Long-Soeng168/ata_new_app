import 'dart:convert';
import 'package:ata_new_app/models/cart_item.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  CartProvider() {
    _loadCartItems();
  }

  // Load cart items from shared preferences
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');

    if (cartData != null) {
      List<dynamic> decodedData = json.decode(cartData);
      _items
          .addAll(decodedData.map((item) => CartItem.fromJson(item)).toList());
    }
    notifyListeners();
  }

  // Save cart items to shared preferences
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
  }

  void addToCart(VideoPlaylist videoPlaylist) {
    // Check if the item is already in the cart
    final existingItem =
        _items.indexWhere((item) => item.videoPlaylist.id == videoPlaylist.id);

    if (existingItem >= 0) {
      // If item exists, increase quantity
      // _items[existingItem].quantity++;
    } else {
      // Otherwise, add a new item
      _items.add(CartItem(videoPlaylist: videoPlaylist));
    }
    _saveCartItems(); // Save to storage
    notifyListeners();
  }

  // Optional: Method to remove an item from the cart
  void removeFromCart(int id) {
    _items.removeWhere((item) => item.videoPlaylist.id == id);
    _saveCartItems(); // Save to storage
    notifyListeners();
  }

  // Increase quantity
  void increaseQuantity(int id) {
    // final index = _items.indexWhere((item) => item.videoPlaylist.id == id);
    // if (index >= 0) {
    //   _items[index].quantity++;
    //   _saveCartItems();  // Save to storage
    //   notifyListeners();
    // }
  }

  // Decrease quantity
  void decreaseQuantity(int id) {
    // final index = _items.indexWhere((item) => item.videoPlaylist.id == id);
    // if (index >= 0 && _items[index].quantity > 1) {
    //   _items[index].quantity--;
    //   _saveCartItems();  // Save to storage
    //   notifyListeners();
    // }
  }

  // Calculate total price
  double totalPrice() {
    return _items.fold(
      0.0,
      (total, item) =>
          total + (double.parse(item.videoPlaylist.price) * item.quantity),
    );
  }

  int totalItems() {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  void clearCart() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('cart_items'); // Remove cart items from shared preferences
    notifyListeners(); // Notify listeners to update the UI
  }
}
