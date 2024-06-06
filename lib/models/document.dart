import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:saferead/crypto_utils.dart';

class Doc {
  final String title;
  Uint8List? data;
  int currentPage;

  Doc(this.title, {this.data, this.currentPage=1});

  Future<Uint8List> decryptDocument(SecretKey key) async {
    List<int> data = this.data as List<int>;
    return await decryptUtil(data, key);
  }

  Future<String> decryptTitle(SecretKey key) async {
    var titleInts = hexStringToIntList(title);
    var t = await decryptUtil(titleInts, key) as List<int>;
    return String.fromCharCodes(t);
  }
}