import 'package:flutter/material.dart';
import '../backend/firebase_manager.dart';
import 'cart_manager.dart';
import 'haptic_manager.dart';

class FavoritesManager extends ValueNotifier<List<FoodItem>> {
  static final FavoritesManager instance = FavoritesManager._internal();

  FavoritesManager._internal() : super([]) {
    loadCloudAndLocalFavorites();
  }

  Future<void> loadCloudAndLocalFavorites() async {
    try {
      final cloudList = await FirebaseManager.instance.fetchUserFavoritesFromCloud();
      if (cloudList.isNotEmpty) {
        value = cloudList;
      }
    } catch (e) {
      debugPrint("Favorites load note: $e");
    }
  }

  bool isFavorite(dynamic itemOrId) {
    if (itemOrId is FoodItem) {
      return value.any((it) =>
          (it.id.isNotEmpty && it.id == itemOrId.id) ||
          it.name.trim().toLowerCase() == itemOrId.name.trim().toLowerCase());
    }
    final String foodId = itemOrId.toString();
    return value.any((it) => it.id == foodId || it.name.trim().toLowerCase() == foodId.trim().toLowerCase());
  }

  void toggleFavorite(FoodItem item) {
    HapticManager.instance.selectionClick();
    final list = List<FoodItem>.from(value);
    final index = list.indexWhere((it) =>
        (it.id.isNotEmpty && it.id == item.id) ||
        it.name.trim().toLowerCase() == item.name.trim().toLowerCase());
    
    bool isNowFav = false;
    if (index >= 0) {
      list.removeAt(index);
      isNowFav = false;
    } else {
      list.add(item);
      isNowFav = true;
    }
    value = list;
    FirebaseManager.instance.syncFavoriteDishToCloud(item, isNowFav);
  }

  void removeFavorite(dynamic itemOrId) {
    final list = List<FoodItem>.from(value);
    FoodItem? removedItem;

    if (itemOrId is FoodItem) {
      removedItem = itemOrId;
      list.removeWhere((it) =>
          (it.id.isNotEmpty && it.id == itemOrId.id) ||
          it.name.trim().toLowerCase() == itemOrId.name.trim().toLowerCase());
    } else {
      final String foodId = itemOrId.toString();
      final idx = list.indexWhere((it) => it.id == foodId || it.name.trim().toLowerCase() == foodId.trim().toLowerCase());
      if (idx >= 0) {
        removedItem = list[idx];
        list.removeAt(idx);
      }
    }
    value = list;
    if (removedItem != null) {
      FirebaseManager.instance.syncFavoriteDishToCloud(removedItem, false);
    }
  }

  void clearFavorites() {
    value = [];
  }
}
