import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

class Encryption {
  static final Encryption instance = Encryption._init();

  late final IV _iv;
  late final Encrypter _encrypter;

  Encryption._init() {
    final keyUtf8 = utf8.encode("11a1215l0119a140409p0919");
    final ivUtf8 = utf8.encode("23a1dfr5lyhd9a1404845001");

    // Generate SHA256 hash, extract first 32 bytes for key, 16 bytes for IV
    final keyBytes = sha256.convert(keyUtf8).bytes.sublist(0, 32);
    final ivBytes = sha256.convert(ivUtf8).bytes.sublist(0, 16);

    _iv = IV(Uint8List.fromList(ivBytes));
    _encrypter = Encrypter(AES(Key(Uint8List.fromList(keyBytes)), mode: AESMode.cbc));

    log("Dart Key (Base64): ${base64Encode(keyBytes)}");
    log("Dart IV (Base64): ${base64Encode(ivBytes)}");
  }

  String encrypt(String value) {
    log("Encrypting Value: $value");
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String base64value) {
    final encrypted = Encrypted.fromBase64(base64value);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}