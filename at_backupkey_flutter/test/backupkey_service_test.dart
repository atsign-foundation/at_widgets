import 'dart:convert';
import 'dart:io';

import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_backupkey_flutter/utils/strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'at_demo_credentials.dart' as demo_data;
import 'package:at_commons/at_commons.dart';
import 'package:at_client/src/util/encryption_util.dart';

void main() {
  String atsign = '@alice🛠';
  setUp(() async => await setUpFunc(atsign));

  group('Fetching AESKey', () {
    test('for registered @sign', () async {
      MockDataService _mockDataService = MockDataService(atsign);
      String aesKey = _mockDataService.getAESKey;
      expect(aesKey != null, true);
      expect(aesKey.length == 44, true);
    });

    test('for unregistered @sign', () async {
      MockDataService _mockDataService = MockDataService(atsign + '123');
      String aesKey = _mockDataService.getAESKey;
      expect(aesKey, null);
    });
  });

  group('Fetch EncryptedKeys', () {
    test('for registerd @sign', () async {
      MockDataService _mockDataService = MockDataService(atsign);
      var map = _mockDataService.getEncryptedKeys();
      expect(map != null, true);
    });

    test('for unregisterd @sign', () async {
      MockDataService _mockDataService = MockDataService(atsign + '123');
      var map = _mockDataService.getEncryptedKeys();
      expect(map, {});
    });
  });

  group('generate backupkey file', () {
    test('for registered @sign', () async {
      MockDataService _mockDataService = MockDataService(atsign);
      var aesEncryptedKeys = _mockDataService.getEncryptedKeys();
      expect(aesEncryptedKeys.isNotEmpty, true);
      var result = await _generateFile(atsign, aesEncryptedKeys);
      expect(result, true);
      expect(await File('test/backup/${atsign}_key.atKeys').exists(), true);
    });

    test('for unregistered @sign', () async {
      String atSign = atsign + '123';
      MockDataService _mockDataService = MockDataService(atSign);
      var aesEncryptedKeys = _mockDataService.getEncryptedKeys();
      expect(aesEncryptedKeys.isNotEmpty, false);
      var result = await _generateFile(atSign, aesEncryptedKeys);
      expect(result, false);
      expect(await File('test/backup/${atSign}_key.atKeys').exists(), false);
    });
  });

  try {
    tearDown(() async => await tearDownFunc());
  } on Exception catch (e) {
    print('error in tear down:${e.toString()}');
  }
}

Future<void> tearDownFunc() async {
  var isExists = await Directory('test/hive').exists();
  if (isExists) {
    Directory('test/hive').deleteSync(recursive: true);
  }
}

Future<void> setUpFunc(String atsign) async {
  var preference = getAtSignPreference(atsign);

  await AtClientImpl.createClient(atsign, 'persona', preference);
  var atClient = await AtClientImpl.getClient(atsign);
  atClient.getSyncManager().init(atsign, preference,
      atClient.getRemoteSecondary(), atClient.getLocalSecondary());
  await atClient.getSyncManager().sync();
  // To setup encryption keys
  await atClient.getLocalSecondary().putValue(
      AT_ENCRYPTION_PRIVATE_KEY, demo_data.encryptionPrivateKeyMap[atsign]);
}

AtClientPreference getAtSignPreference(String atsign) {
  var preference = AtClientPreference();
  preference.hiveStoragePath = 'test/hive/client';
  preference.commitLogPath = 'test/hive/client/commit';
  preference.isLocalStoreRequired = true;
  preference.syncStrategy = SyncStrategy.IMMEDIATE;
  preference.privateKey = demo_data.pkamPrivateKeyMap[atsign];
  preference.rootDomain = 'vip.ve.atsign.zone';
  return preference;
}

Future<bool> _generateFile(
    String atsign, Map<String, String> aesEncryptedKeys) async {
  if (aesEncryptedKeys.isEmpty) {
    return false;
  }
  var directory = Directory('test/backup');
  String path = directory.path.toString() + '/';
  final encryptedKeysFile =
      await File('$path' + '$atsign${Strings.backupKeyName}').create();
  var keyString = jsonEncode(aesEncryptedKeys);
  encryptedKeysFile.writeAsStringSync(keyString);
  return true;
}

class MockDataService {
  final atsign;

  MockDataService(this.atsign);
  get getAESKey => demo_data.aesKeyMap[atsign];

  Map<String, String> getEncryptedKeys() {
    var aesEncryptedKeys = {};

    try {
      // encrypt pkamPublicKey with AES key
      var pkamPublicKey = demo_data.pkamPublicKeyMap[atsign];
      var aesEncryptionKey = getAESKey;
      var encryptedPkamPublicKey =
          EncryptionUtil.encryptValue(pkamPublicKey, aesEncryptionKey);
      aesEncryptedKeys[BackupKeyConstants.PKAM_PUBLIC_KEY_FROM_KEY_FILE] =
          encryptedPkamPublicKey;

      // encrypt pkamPrivateKey with AES key
      var pkamPrivateKey = demo_data.pkamPrivateKeyMap[atsign];
      var encryptedPkamPrivateKey =
          EncryptionUtil.encryptValue(pkamPrivateKey, aesEncryptionKey);
      aesEncryptedKeys[BackupKeyConstants.PKAM_PRIVATE_KEY_FROM_KEY_FILE] =
          encryptedPkamPrivateKey;

      // encrypt encryption public key with AES key
      var encryptionPublicKey = demo_data.encryptionPublicKeyMap[atsign];
      var encryptedEncryptionPublicKey =
          EncryptionUtil.encryptValue(encryptionPublicKey, aesEncryptionKey);
      aesEncryptedKeys[BackupKeyConstants.ENCRYPTION_PUBLIC_KEY_FROM_FILE] =
          encryptedEncryptionPublicKey;

      // encrypt encryption private key with AES key
      var encryptionPrivateKey = demo_data.encryptionPrivateKeyMap[atsign];
      var encryptedEncryptionPrivateKey =
          EncryptionUtil.encryptValue(encryptionPrivateKey, aesEncryptionKey);
      aesEncryptedKeys[BackupKeyConstants.ENCRYPTION_PRIVATE_KEY_FROM_FILE] =
          encryptedEncryptionPrivateKey;

      // store  self encryption key as it is.This will be same as AES key in key zip file
      var selfEncryptionKey = getAESKey;
      aesEncryptedKeys[BackupKeyConstants.SELF_ENCRYPTION_KEY_FROM_FILE] =
          selfEncryptionKey;
      aesEncryptedKeys[atsign] = getAESKey;

      return Map<String, String>.from(aesEncryptedKeys);
    } catch (e) {
      return Map<String, String>.from(aesEncryptedKeys);
    }
  }
}
