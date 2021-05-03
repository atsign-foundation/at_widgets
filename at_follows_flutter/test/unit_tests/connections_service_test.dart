import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../at_demo_credentials.dart' as demo_data;
import 'package:at_commons/at_commons.dart';

SDKService _sdkService = SDKService();
ConnectionsService _connectionsService = ConnectionsService();

void main() {
  String senderAtsign = '@alice🛠';

  setUp(() async {
    _sdkService.setClientService = await setUpFunc(senderAtsign);
    _connectionsService.init();
    ConnectionProvider().init();
    await _sdkService.startMonitor(monitorCallBack);
  });

  group('test follow functionality', () {
    test('with valid @sign', () async {
      String receiverAtsign = '@bob🛠';

      var receiverAtClientService = await setUpFunc(receiverAtsign);
      await receiverAtClientService.atClient.startMonitor(
          receiverAtClientService.atClient.preference.privateKey,
          monitorCallBack);
      Atsign atsign = await _connectionsService.follow(receiverAtsign);
      expect(atsign.title, receiverAtsign);
      expect(
          _connectionsService.following.list.contains(receiverAtsign), isTrue);
    });

    test('with same @sign', () async {
      Atsign atsign = await _connectionsService.follow(senderAtsign);
      expect(atsign, null);
      expect(
          _connectionsService.following.list.contains(senderAtsign), isFalse);
    });

    test('with existing @sign', () async {
      String receiverAtsign = '@bob🛠';
      Atsign atsign = await _connectionsService.follow(receiverAtsign);
      expect(atsign.title, receiverAtsign);
      expect(
          _connectionsService.following.list.contains(receiverAtsign), isTrue);
      Atsign atsign1 = await _connectionsService.follow(receiverAtsign);
      expect(atsign1, null);
      expect(
          _connectionsService.following.list.contains(receiverAtsign), isFalse);
    });
  });

  group('test unfollow functionality', () {
    test('with existing @sign', () async {
      String receiverAtsign = '@bob🛠';
      _connectionsService.following.add(receiverAtsign);
      var receiverAtClientService = await setUpFunc(receiverAtsign);
      await receiverAtClientService.atClient.startMonitor(
          receiverAtClientService.atClient.preference.privateKey,
          monitorCallBack);
      bool result = await _connectionsService.unfollow(receiverAtsign);
      expect(result, true);
      expect(
          _connectionsService.following.list.contains(receiverAtsign), isFalse);
    });

    test('with same @sign', () async {
      bool result = await _connectionsService.unfollow(senderAtsign);
      expect(result, false);
      expect(
          _connectionsService.following.list.contains(senderAtsign), isFalse);
    });

    test('with non existing @sign', () async {
      String receiverAtsign = '@bob🛠';
      bool result = await _connectionsService.unfollow(receiverAtsign);
      expect(result, false);
      expect(
          _connectionsService.following.list.contains(receiverAtsign), isFalse);
    });
  });
}

Future<void> tearDownFunc() async {
  var isExists = await Directory('test/hive').exists();
  if (isExists) {
    Directory('test/hive').deleteSync(recursive: true);
  }
}

Future<AtClientService> setUpFunc(String atsign) async {
  var preference = getAtSignPreference(atsign);

  AtClientService atClientService = AtClientService();

  await AtClientImpl.createClient(atsign, 'persona', preference);
  var atClient = await AtClientImpl.getClient(atsign);
  atClientService.atClient = atClient;
  atClient.getSyncManager().init(atsign, preference,
      atClient.getRemoteSecondary(), atClient.getLocalSecondary());
  await atClient.getSyncManager().sync();
  await atClient
      .getLocalSecondary()
      .putValue(AT_PKAM_PRIVATE_KEY, demo_data.pkamPrivateKeyMap[atsign]);
  await atClient.getLocalSecondary().putValue(
      AT_ENCRYPTION_PRIVATE_KEY, demo_data.encryptionPrivateKeyMap[atsign]);
  return atClientService;
}

monitorCallBack(var response) {
  if (response == null) {
    return;
  }
  response = response.toString().replaceAll('notification:', '').trim();
  var notification = AtNotification.fromJson(jsonDecode(response));
  print(
      'Received notification:: id:${notification.id} key:${notification.key} operation:${notification.operation} from:${notification.fromAtSign} to:${notification.toAtSign}');
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
