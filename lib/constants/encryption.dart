import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

class Encryption {
  String encryption(String data, String sixteendigits) {
    final key = enc.Key.fromUtf8(sixteendigits);
    final iv = enc.IV.fromLength(16);

    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64.toString();
  }

  String decrypted(String encryptedData, String sixteendigits) {
    final key = enc.Key.fromUtf8(sixteendigits);
    final iv = enc.IV.fromLength(16);

    final encrypter = enc.Encrypter(enc.AES(key));

    final decrypt = encrypter.decrypt64(encryptedData, iv: iv);
    return decrypt.toString();
  }
}
