import 'dart:convert';

import 'package:at_follows_flutter/domain/at_follows_list.dart';
import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';
import 'package:at_follows_flutter/utils/app_constants.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

class ConnectionsService {
  static final ConnectionsService _singleton = ConnectionsService._internal();

  late AtFollowsList followers;
  late AtFollowsList following;
  String? followerAtsign;
  String? followAtsign;
  String initialised = '';

  final AtSignLogger _logger = AtSignLogger('Connections Service');

  final SDKService _sdkService = SDKService();

  ConnectionsService._internal();

  factory ConnectionsService() {
    return _singleton;
  }

  ConnectionProvider connectionProvider = ConnectionProvider();

  late bool isMonitorStarted;

  void init(String atsign) {
    if (atsign != initialised) {
      followers = AtFollowsList();
      following = AtFollowsList();
      isMonitorStarted = false;
      initialised = atsign;
    }
  }

  Future<void> getAtsignsList({bool isInit = false}) async {
    if (connectionProvider.followingList!.isEmpty || isInit) {
      await createLists(isFollowing: true);
      if (following.list!.isNotEmpty) {
        connectionProvider.followingList =
            await _formAtSignData(following.list!, isFollowing: true);
      }
      await _sdkService.sync();
      if (!following.contains(followAtsign) &&
          followAtsign != null) {
        Atsign? atsignData = await follow(followAtsign);
        if (atsignData != null) {
          connectionProvider.followingList!.add(atsignData);
        }
        followAtsign = null;
      }
    }
    await _sdkService.sync();
    if (connectionProvider.followersList!.isEmpty || isInit) {
      await createLists(isFollowing: false);
      if (followers.list!.isNotEmpty) {
        connectionProvider.followersList =
            await _formAtSignData(followers.list!);
      }
    }
    if (isInit) {
      DateTime? fromDate = followers.getKey != null
          ? followers.getKey!.metadata?.updatedAt
          : null;
      List<AtNotification> notificationsList =
          await _sdkService.notifyList(fromDate: fromDate?.toString());
      //filtering notifications which has only new followers
      for (AtNotification notification in notificationsList) {
        if (notification.operation == Operation.update) {
          await updateFollowers(notification, isSetStatus: false);
        } else if (notification.operation == Operation.delete &&
            notification.key!.contains(AppConstants.containsFollowing)) {
          await deleteFollowers(notification, isSetStatus: false);
        } else if (notification.operation == Operation.delete &&
            notification.key!.contains(AppConstants.containsFollowers)) {
          await deleteFollowing(notification, isSetStatus: false);
        }
      }
      await _sdkService.sync();
    }
  }

  Future<List<Atsign>> _formAtSignData(List<String?> connectionsList,
      {bool isFollowing = false}) async {
    List<Atsign> atsignList = <Atsign>[];
    for (String? connection in connectionsList) {
      Atsign atsignData =
          await _getAtsignData(connection, isFollowing: isFollowing);
      atsignList.add(atsignData);
    }
    atsignList.sort((Atsign a, Atsign b) => a.title![1].compareTo(b.title![1]));
    return atsignList;
  }

  Future<Atsign?> follow(String? atsign) async {
    if (atsign == _sdkService.atsign) {
      return null;
    }
    atsign = formatAtSign(atsign);
    AtKey atKey = _formKey(isFollowing: true);
    Metadata? atMetadata = atKey.metadata;
    if (following.list!.contains(atsign) || atsign == _sdkService.atsign) {
      return null;
    }
    following.add(atsign);
    bool result = await _sdkService.put(atKey, following.toString());
    await _sdkService.sync();
    //change metadata to private to notify
    if (result) {
      atKey.sharedWith = atsign;
      atMetadata?.isPublic = false;
      atKey.metadata = atMetadata;
      await _sdkService.notify(
          atKey, atsign!, OperationEnum.update, _onNotifyDone, _onNotifyError);
    }
    Atsign atsignData =
        await _getAtsignData(atsign, isNew: true, isFollowing: true);
    await _sdkService.sync();
    return atsignData;
  }

  ///Deletes the [atsign] from followers and following lists.
  Future<bool> delete(String atsign) async {
    bool result;

    //deleting @sign from followers
    AtKey atKey = _formKey();
    Metadata? atMetadata = atKey.metadata;
    result = await _modifyKey(atsign, followers, atKey);
    //notify @sign about delete
    if (result) {
      atKey.sharedWith = atsign;
      atMetadata?.isPublic = false;
      atKey.metadata = atMetadata;
      await _sdkService.notify(
          atKey, atsign, OperationEnum.delete, _onNotifyDone, _onNotifyError);
    }

    //deleting @sign from following
    atKey = _formKey(isFollowing: true);
    atMetadata = atKey.metadata;
    result = await _modifyKey(atsign, following, atKey);
    //notify @sign about delete
    if (result) {
      atKey.sharedWith = atsign;
      atMetadata?.isPublic = false;
      atKey.metadata = atMetadata;
      await _sdkService.notify(
          atKey, atsign, OperationEnum.delete, _onNotifyDone, _onNotifyError);
    }

    await _sdkService.sync();
    return result;
  }

  Future<bool> unfollow(String? atsign) async {
    atsign = formatAtSign(atsign);
    AtKey atKey = _formKey(isFollowing: true);
    Metadata? atMetadata = atKey.metadata;
    bool result = await _modifyKey(atsign, following, atKey);
    if (result) {
      atKey.sharedWith = atsign;
      atMetadata?.isPublic = false;
      atKey.metadata = atMetadata;
      await _sdkService.notify(
          atKey, atsign!, OperationEnum.delete, _onNotifyDone, _onNotifyError);
      await _sdkService.sync();
    }
    return result;
  }

  Future<bool> removeFollower(String atsign) async {
    List<dynamic> followersList = followers.getKey!.value.split(',');
    bool result = false;
    AtKey atKey = _formKey();
    followersList.remove(atsign);
    if (followersList.isNotEmpty) {
      result = await _sdkService.put(atKey, followersList.toString());
      followers.list!.remove(atsign);
    } else {
      result = await _sdkService.put(atKey, 'null');
    }
    return result;
  }

  Future<bool> _modifyKey(
      String? atsign, AtFollowsList atFollowsList, AtKey atKey) async {
    bool result = false;
    if (!atFollowsList.list!.contains(atsign) || atsign == _sdkService.atsign) {
      return false;
    }
    atFollowsList.remove(atsign);
    if (atFollowsList.toString().isEmpty) {
      result = await _sdkService.put(atKey, 'null');
    } else {
      result = await _sdkService.put(atKey, atFollowsList.toString());
    }
    await _sdkService.sync();
    return result;
  }

  ///Returns `true` on changing the status of the list to [isPrivate].
  Future<bool> changeListPublicStatus(bool isFollowing, bool isPrivate) async {
    isFollowing
        ? following.isPrivate = isPrivate
        : followers.isPrivate = isPrivate;
    AtFollowsValue atFollowsValue = AtFollowsValue()
      ..atKey = _formKey(isFollowing: isFollowing);
    bool result = await _sdkService.delete(
        isFollowing ? following.getKey!.atKey : followers.getKey!.atKey);
    isFollowing
        ? following.setKey = atFollowsValue
        : followers.setKey = atFollowsValue;
    String value = isFollowing ? following.toString() : followers.toString();
    result = await _sdkService.put(atFollowsValue.atKey, value);
    await _sdkService.sync();
    return result;
  }

  ///adds [notification.fromAtSign] into followers list.
  Future<void> updateFollowers(AtNotification notification,
      {bool isSetStatus = true}) async {
    try {
      if (isSetStatus) connectionProvider.setStatus(Status.loading);
      AtKey atKey = _formKey();
      if (followers.list!.contains(notification.fromAtSign)) {
        if (isSetStatus) connectionProvider.setStatus(Status.done);
        return;
      }
      followers.add(notification.fromAtSign);
      await _sdkService.put(atKey, followers.toString());
      await _sdkService.sync();
      Atsign atsignData = await _getAtsignData(
        notification.fromAtSign,
        isNew: true,
      );
      connectionProvider.followersList!.add(atsignData);
      if (isSetStatus) {
        connectionProvider.setStatus(Status.done);
        await _sdkService.sync();
      }
    } catch (err) {
      connectionProvider.error = err;
      connectionProvider.setStatus(Status.error);
    }
  }

  ///deletes [notification.fromAtSign] from followers list.
  Future<void> deleteFollowers(AtNotification notification,
      {bool isSetStatus = true}) async {
    try {
      if (isSetStatus) connectionProvider.setStatus(Status.loading);
      if (!followers.list!.contains(notification.fromAtSign)) {
        if (isSetStatus) connectionProvider.setStatus(Status.done);
        return;
      }
      followers.remove(notification.fromAtSign);
      AtKey atKey = _formKey();
      followers.list!.isNotEmpty
          ? await _sdkService.put(atKey, followers.toString())
          : await _sdkService.put(atKey, 'null');

      connectionProvider.followersList!
          .removeWhere((Atsign element) => element.title == notification.fromAtSign);
      if (isSetStatus) {
        connectionProvider.setStatus(Status.done);
        await _sdkService.sync();
      }
    } catch (err) {
      connectionProvider.error = err;
      connectionProvider.setStatus(Status.error);
    }
  }

  ///deletes [notification.fromAtSign] from following list.
  Future<void> deleteFollowing(AtNotification notification,
      {bool isSetStatus = true}) async {
    try {
      if (isSetStatus) connectionProvider.setStatus(Status.loading);
      if (!following.list!.contains(notification.fromAtSign)) {
        if (isSetStatus) connectionProvider.setStatus(Status.done);
        return;
      }
      following.remove(notification.fromAtSign);
      AtKey atKey = _formKey(isFollowing: true);
      following.list!.isNotEmpty
          ? await _sdkService.put(atKey, following.toString())
          : await _sdkService.put(atKey, 'null');

      connectionProvider.followingList!
          .removeWhere((Atsign element) => element.title == notification.fromAtSign);
      if (isSetStatus) {
        connectionProvider.setStatus(Status.done);
        await _sdkService.sync();
      }
    } catch (err) {
      connectionProvider.error = err;
      connectionProvider.setStatus(Status.error);
    }
  }

  ///creates following and followers list.
  Future<void> createLists({required bool isFollowing}) async {
    // for following list followers list is not required.
    if (!isFollowing) {
      AtFollowsValue? followersValue = await _sdkService
          .scanAndGet(AppConstants.containsFollowers);
      followers.create(followersValue!);
      if (followersValue.metadata != null) {
        connectionProvider.connectionslistStatus.isFollowersPrivate =
            !followersValue.metadata!.isPublic!;
        await _sdkService.sync();
      }
    } else {
      // for followers list following list is required to show the status of follow button.

      AtFollowsValue? followingValue = await _sdkService
          .scanAndGet(AppConstants.containsFollowing);
      following.create(followingValue!);

      if (followingValue.metadata != null) {
        connectionProvider.connectionslistStatus.isFollowingPrivate =
            !followingValue.metadata!.isPublic!;
        await _sdkService.sync();
      }
    }
  }

  void _onNotifyDone(String notifyResult) {
    _logger.finer('notification complete $notifyResult');
  }

  void _onNotifyError(Object error) {
    _logger.finer('notification error ${error.toString()}');
  }

  AtKey _formKey({bool isFollowing = false, String? atsign}) {
    AtKey atKey;
    String? atSign = atsign ?? _sdkService.atsign;
    if (isFollowing) {
      Metadata atMetadata = Metadata()..isPublic = !following.isPrivate;
      atKey = AtKey()
        ..metadata = atMetadata
        ..key = AppConstants.followingKey
        ..sharedWith = atMetadata.isPublic! ? null : atSign;
    } else {
      Metadata atMetadata = Metadata()..isPublic = !followers.isPrivate;
      atKey = AtKey()
        ..metadata = atMetadata
        ..key = AppConstants.followersKey
        ..sharedWith = atMetadata.isPublic! ? null : atSign;
    }
    return atKey;
  }

  Future<Atsign> _getAtsignData(String? connection,
      {bool isFollowing = true, bool isNew = false}) async {
    AtKey atKey;
    Atsign atsignData = Atsign()
      ..title = connection
      ..isFollowing = following.list!.contains(connection);
    try {
      Atsign? data = connectionProvider.getData(!isFollowing, connection);
      if (data != null) {
        return data;
      }
      atKey = AtKey()..sharedBy = connection;
      AtFollowsValue? atValue = AtFollowsValue();
      for (String key in PublicData.list) {
        atKey.metadata = _getPublicFieldsMetadata(key);
        atKey.key = key;
        atKey.sharedWith = null;
        atValue = await _sdkService.get(atKey);
        //performs plookup if the data is not in cache.
        if (atValue!.value == null) {
          //plookup for wavi keys.
          atKey.metadata!.isCached = false;
          atValue = await _sdkService.get(atKey);
          //cache lookup for persona keys
          if (atValue!.value == null) {
            atKey.key = PublicData.personaMap[key];
            atKey.metadata!.isCached = true;
            atValue = await _sdkService.get(atKey);
            //plookup for persona keys.
            if (atValue!.value == null) {
              atKey.metadata!.isCached = false;
              atValue = await _sdkService.get(atKey);
            }
          }
        }

        atsignData.setData(atValue!);
      }
    } on AtLookUpException catch (e) {
      _logger.severe('Fetching keys for $connection throws ${e.errorMessage}');
    }

    return atsignData;
  }

  Metadata _getPublicFieldsMetadata(String key) {
    Metadata atmetadata = Metadata()
      ..namespaceAware = false
      ..isCached = true
      ..isBinary = key == PublicData.image || key == PublicData.imagePersona
      ..isPublic = true;
    return atmetadata;
  }

  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String? formatAtSign(String? atsign) {
    if (atsign == null) {
      return null;
    } else if (atsign.contains(':')) {
      return Strings.invalidAtsign;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }

  bool startMonitor() {
    AtClientManager.getInstance().notificationService.subscribe().listen((notification) {
      acceptStream(notification);
    });
    return true;
  }

  //#TODO change this implementation when testing
  Future<void> acceptStream(String? response) async {
    if (response == null) {
      return;
    }
    response = response.toString().replaceAll('notification:', '').trim();
    AtNotification notification = AtNotification.fromJson(jsonDecode(response));
    _logger.info(
        'Received notification:: id:${notification.id} key:${notification.key} operation:${notification.operation} from:${notification.fromAtSign} to:${notification.toAtSign}');
    if (notification.operation == Operation.update &&
        notification.toAtSign == _sdkService.atsign &&
        notification.key!.contains(AppConstants.containsFollowing)) {
      await updateFollowers(notification);
    } else if (notification.operation == Operation.delete &&
        notification.toAtSign == _sdkService.atsign &&
        notification.key!.contains(AppConstants.containsFollowing)) {
      await deleteFollowers(notification);
    } else if (notification.operation == Operation.delete &&
        notification.toAtSign == _sdkService.atsign &&
        notification.key!.contains(AppConstants.containsFollowers)) {
      await deleteFollowing(notification);
    }
  }
}

class AtNotification {
  String? id;
  String? fromAtSign;
  String? toAtSign;
  String? key;
  String? value;
  String? operation;
  int? dateTime;

  AtNotification(
      {this.id,
      this.fromAtSign,
      this.toAtSign,
      this.key,
      this.value,
      this.dateTime,
      this.operation});

  factory AtNotification.fromJson(Map<String, dynamic> json) {
    return AtNotification(
      id: json['id'],
      fromAtSign: json['from'],
      dateTime: json['epochMillis'],
      toAtSign: json['to'],
      key: json['key'],
      operation: json['operation'],
      value: json['value'],
    );
  }

  static List<AtNotification> fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    List<AtNotification> notificationList = <AtNotification>[];
    for (Map<String, dynamic> json in jsonList) {
      notificationList.add(AtNotification.fromJson(json));
    }
    return notificationList;
  }
}

class AtFollowsValue extends AtValue {
  late AtKey atKey;
}

class Operation {
  static final String update = 'update';
  static final String delete = 'delete';
}
