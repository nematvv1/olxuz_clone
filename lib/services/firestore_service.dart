import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ads_model.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _adsRef = _firestore.collection('ads');

  static Future<void> addAd(AdsModel ad) async {
    await _adsRef.add(ad.toJson());
  }

  static Future<List<AdsModel>> getAds() async {
    final snapshot = await _adsRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdsModel.fromJson(data)..id = doc.id;
    }).toList();
  }

  static Future<List<AdsModel>> getUserAds(String uid) async {
    final snapshot = await _adsRef.where('uid', isEqualTo: uid).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdsModel.fromJson(data)..id = doc.id;
    }).toList();
  }
}
