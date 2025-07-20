import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAapZN8-wAcq82oG7IsxGTevPbkQ3w2IMI",
    authDomain: "insta-2e213.firebaseapp.com",
    projectId: "insta-2e213",
    storageBucket: "insta-2e213.appspot.com",
    messagingSenderId: "584918980946",
    appId: "1:584918980946:web:d57981ec24c0223bda428b",
    measurementId: "G-V3X4PN5VP1",
  );
}
