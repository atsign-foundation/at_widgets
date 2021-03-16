import 'dart:convert';

import 'package:at_follows_flutter/domain/at_follows_list.dart';
import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';
import 'package:at_follows_flutter/utils/app_constants.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_utils/at_logger.dart';

class ConnectionsService {
  static final ConnectionsService _singleton = ConnectionsService._internal();

  AtFollowsList followers;
  AtFollowsList following;
  String followerAtsign;
  String followAtsign;

  var _logger = AtSignLogger('Connections Service');

  SDKService _sdkService = SDKService();

  ConnectionsService._internal();

  factory ConnectionsService() {
    return _singleton;
  }

  var connectionProvider = ConnectionProvider();

  bool isMonitorStarted = false;

  init() {
    followers = AtFollowsList();
    following = AtFollowsList();
  }

  Future<List<Atsign>> getAtsignsList({bool isFollowing = false}) async {
    List<Atsign> atsignList = [];
    await createLists(isFollowing);
    var connectionsList = isFollowing ? following.list : followers.list;
    for (var connection in connectionsList) {
      var atsignData = await _getAtsignData(connection);
      atsignList.add(atsignData);
    }
    atsignList.sort((a, b) => a.title[1].compareTo(b.title[1]));
    return atsignList;
  }

  Future<Atsign> follow(String atsign) async {
    if (atsign == _sdkService.atsign) {
      return null;
    }
    atsign = formatAtSign(atsign);
    var atKey = this._formKey(isFollowing: true);
    var atMetadata = atKey.metadata;
    if (following.list.contains(atsign)) {
      return null;
    }
    following.add(atsign);
    var result = await _sdkService.put(atKey, following.toString());
    //change metadata to private to notify
    if (atMetadata.isPublic) {
      atKey..sharedWith = atsign;
      atMetadata..isPublic = false;
      atKey..metadata = atMetadata;
      result = await _sdkService.notify(atKey, atsign, OperationEnum.update);
    }
    var atsignData = await _getAtsignData(atsign);
    await _sdkService.sync();
    return atsignData;
  }

  Future<bool> unfollow(String atsign) async {
    atsign = formatAtSign(atsign);
    var atKey = this._formKey(isFollowing: true);
    var atMetadata = atKey.metadata;
    var result;
    if (!following.list.contains(atsign)) {
      return false;
    }
    following.remove(atsign);
    if (following.toString().isEmpty) {
      result = await _sdkService.delete(atKey);
    } else {
      result = await _sdkService.put(atKey, following.toString());
    }
    //change metadata to private to notify
    if (atMetadata.isPublic) {
      atKey..sharedWith = atsign;
      atMetadata..isPublic = false;
      atKey..metadata = atMetadata;
      result = await _sdkService.notify(atKey, atsign, OperationEnum.delete);
    }
    await _sdkService.sync();
    return result;
  }

  Future<bool> changeListPublicStatus(
      bool isFollowing, bool statusValue) async {
    isFollowing
        ? following.isPrivate = statusValue
        : followers.isPrivate = statusValue;
    var atKey = _formKey(isFollowing: isFollowing);
    bool result = await this
        ._sdkService
        .delete(isFollowing ? following.getKey : followers.getKey);
    isFollowing ? following.setKey = atKey : followers.setKey = atKey;
    String value = isFollowing ? following.toString() : followers.toString();
    result = await this._sdkService.put(atKey, value);
    _sdkService.sync();
    return result;
  }

  updateFollowers(AtNotification notification) async {
    var connectionProvider = ConnectionProvider();
    try {
      connectionProvider.setStatus(Status.loading);
      var atKey = this._formKey();
      if (followers.list.contains(notification.fromAtSign)) {
        connectionProvider.setStatus(Status.done);
        return true;
      }
      followers.add(notification.fromAtSign);
      await _sdkService.put(atKey, followers.toString());
      var atsignData = await _getAtsignData(notification.fromAtSign);
      connectionProvider.followersList.add(atsignData);
      connectionProvider.setStatus(Status.done);
      await _sdkService.sync();
    } catch (err) {
      connectionProvider.error = err;
      connectionProvider.setStatus(Status.error);
    }
  }

  deleteFollowers(AtNotification notification) async {
    var connectionProvider = ConnectionProvider();
    try {
      connectionProvider.setStatus(Status.loading);
      if (!followers.list.contains(notification.fromAtSign)) {
        connectionProvider.setStatus(Status.done);
        return true;
      }
      followers.remove(notification.fromAtSign);
      var atKey = this._formKey();
      followers.list.isNotEmpty
          ? await _sdkService.put(atKey, followers.toString())
          : await this._sdkService.delete(atKey);
      connectionProvider.followersList
          .removeWhere((element) => element.title == notification.fromAtSign);
      connectionProvider.setStatus(Status.done);
      await _sdkService.sync();
    } catch (err) {
      connectionProvider.error = err;
      connectionProvider.setStatus(Status.error);
    }
  }

  ///creates following and followers list.
  Future<void> createLists(bool isFollowing) async {
    // for following list followers list is not required.
    if (!isFollowing) {
      var followersValue = await _sdkService.scanAndGet(AppConstants.followers);
      this.followers.create(followersValue);
      if (followersValue.metadata != null) {
        connectionProvider.connectionslistStatus.isFollowersPrivate =
            !followersValue.metadata.isPublic;
      }
    }
    // for followers list following list is required to show the status of follow button.
    var followingValue = await _sdkService.scanAndGet(AppConstants.following);
    this.following.create(followingValue);
    if (followingValue.metadata != null) {
      connectionProvider.connectionslistStatus.isFollowingPrivate =
          !followingValue.metadata.isPublic;
    }
  }

  AtKey _formKey({bool isFollowing = false}) {
    var atKey;
    var atSign = _sdkService.atsign;
    if (isFollowing) {
      var atMetadata = Metadata()..isPublic = !following.isPrivate;
      atKey = AtKey()
        ..metadata = atMetadata
        ..key = AppConstants.following
        ..sharedWith = atMetadata.isPublic ? null : atSign;
    } else {
      var atMetadata = Metadata()..isPublic = !followers.isPrivate;
      atKey = AtKey()
        ..metadata = atMetadata
        ..key = AppConstants.followers
        ..sharedWith = atMetadata.isPublic ? null : atSign;
    }
    return atKey;
  }

  Future<Atsign> _getAtsignData(String connection) async {
    AtKey atKey;
    Atsign atsignData = Atsign()
      ..title = connection
      ..isFollowing = following.list.contains(connection);
    atKey = AtKey()..sharedBy = connection;
    AtFollowsValue atValue = AtFollowsValue();
    for (var key in PublicData.list) {
      atKey..metadata = _getPublicFieldsMetadata(key);
      atKey..key = key;
      atValue = await _sdkService.get(atKey);
      atValue..atKey = atKey;
      atsignData.setData(atValue);
    }
    return atsignData;
  }

  _getPublicFieldsMetadata(String key) {
    var atmetadata = Metadata()
      ..namespaceAware = false
      ..isBinary = key == PublicData.image
      ..isPublic = true;
    return atmetadata;
  }

  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String formatAtSign(String atsign) {
    if (atsign == null) {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }

  Future<bool> startMonitor() async {
    await _sdkService.startMonitor(acceptStream);
    isMonitorStarted = true;
    return true;
  }

  acceptStream(var response) async {
    if (response == null) {
      return;
    }
    response = response.toString().replaceAll('notification:', '').trim();
    var notification = AtNotification.fromJson(jsonDecode(response));
    _logger.info(
        'Received notification:: id:${notification.id} key:${notification.key} operation:${notification.operation} from:${notification.fromAtSign} to:${notification.toAtSign}');
    if (notification.operation == Operation.update) {
      await updateFollowers(notification);
    } else if (notification.operation == Operation.delete) {
      await deleteFollowers(notification);
    }
  }
}

class AtNotification {
  String id;
  String fromAtSign;
  String toAtSign;
  String key;
  String value;
  String operation;
  int dateTime;

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
}

class AtFollowsValue extends AtValue {
  AtKey atKey;
}

class Operation {
  static final String update = 'update';
  static final String delete = 'delete';
}
