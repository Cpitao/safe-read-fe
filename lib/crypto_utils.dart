import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

Future<SecretKey> getKey(String username, String password) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 10000,
    bits: 256);
  
  return await pbkdf2.deriveKeyFromPassword(
    password: password,
    nonce: username.codeUnits,
  );
}

Future<List<int>> encryptUtil(SecretKey key, List<int> data) async {
  final aes = AesCbc.with256bits(
    macAlgorithm: Hmac.sha256(),
  );
  var result = await aes.encrypt(data, secretKey: key);
  
  return result.concatenation();
}

Future<Uint8List> decryptUtil(List<int> data, SecretKey key) async {
  final aes = AesCbc.with256bits(
    macAlgorithm: Hmac.sha256(),
  );
  final secretBox = SecretBox.fromConcatenation(
    data,
    nonceLength: aes.nonceLength,
    macLength: aes.macAlgorithm.macLength
  );

  return await aes.decrypt(secretBox, secretKey: key) as Uint8List;
}

List<int> hexStringToIntList(String hexString) {
  return hex.decode(hexString);
}