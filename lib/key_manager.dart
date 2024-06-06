import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

class KeyManager extends ChangeNotifier {
  late Map<String, SecretKey> keys;

  KeyManager() {
    keys = <String, SecretKey>{};
  }
}