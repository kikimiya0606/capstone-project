import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web 앱이 아직 Firebase 콘솔에 등록되지 않았습니다. Web 앱 등록 후 이 파일에 web 옵션을 추가하세요.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        throw UnsupportedError(
          'Android 앱이 아직 Firebase 콘솔에 등록되지 않았습니다. Android 앱 등록 후 이 파일에 android 옵션을 추가하세요.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 현재 iOS만 지원합니다.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuTbBdRNwww2SxJ1q_UEa9T8w-PyHmEEc',
    appId: '1:564336576115:ios:aa910de3614b2e399d4c06',
    messagingSenderId: '564336576115',
    projectId: 'mood-12672',
    storageBucket: 'mood-12672.firebasestorage.app',
    iosBundleId: 'com.a1hajo.mira',
  );
}
