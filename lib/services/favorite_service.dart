import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static Future<void> addFavorite(String adId, Map<String, dynamic> adData) async {
    await _firestore
        .collection('favorites')
        .doc(_uid)
        .collection('likedAds')
        .doc(adId)
        .set(adData);
  }

  static Future<void> removeFavorite(String adId) async {
    await _firestore
        .collection('favorites')
        .doc(_uid)
        .collection('likedAds')
        .doc(adId)
        .delete();
  }

  static Future<bool> isFavorite(String adId) async {
    var doc = await _firestore
        .collection('favorites')
        .doc(_uid)
        .collection('likedAds')
        .doc(adId)
        .get();
    return doc.exists;
  }

  static Stream<List<Map<String, dynamic>>> getFavorites() {
    return _firestore
        .collection('favorites')
        .doc(_uid)
        .collection('likedAds')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }
}
