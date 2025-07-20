import 'package:flutter/cupertino.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> _favoriteIds = [];

  void setFavorites(List<String> ids) {
    _favoriteIds = ids;
    notifyListeners();
  }

  void addFavorite(String id) {
    if (!_favoriteIds.contains(id)) {
      _favoriteIds.add(id);
      notifyListeners();
    }
  }

  void removeFavorite(String id) {
    _favoriteIds.remove(id);
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);
}
