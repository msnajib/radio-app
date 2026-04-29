import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7mzkobtOYqwQF4u0Z0seZqSGnwdtGHFI',
    appId: '1:753404381293:android:3649bc7c08dfb75d9ed764',
    messagingSenderId: '753404381293',
    projectId: 'radio-app-3c542',
    storageBucket: 'radio-app-3c542.firebasestorage.app',
  );
}
