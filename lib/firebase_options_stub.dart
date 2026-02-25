// This is a stub file that provides DefaultFirebaseOptions when firebase_options.dart doesn't exist.
// Run `flutterfire configure` to generate the real firebase_options.dart file.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase not configured. Run `flutterfire configure` to generate firebase_options.dart',
    );
  }
}

