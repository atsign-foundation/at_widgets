import 'dart:async';

import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';

class ConnectionProvider extends ChangeNotifier {
  static final ConnectionProvider _singleton = ConnectionProvider._internal();
  ConnectionProvider._internal();

  final AtSignLogger _logger = AtSignLogger('Connection Provider');

  factory ConnectionProvider() {
    return _singleton;
  }
  List<Atsign>? followersList;
  List<Atsign>? followingList;
  List<Atsign>? atsignsList;
  Status? status;
  Object? error;
  String initialised = '';

  late ConnectionsService _connectionsService;
  late bool _disposed;
  late ListStatus connectionslistStatus;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void init(String atsign) {
    if (atsign != initialised) {
      followersList = <Atsign>[];
      followingList = <Atsign>[];
      atsignsList = <Atsign>[];
      _connectionsService = ConnectionsService();
      connectionslistStatus = ListStatus();
      _disposed = false;
      setStatus(null);
      initialised = atsign;
    }
  }

  void setStatus(Status? value) {
    status = value;
    notifyListeners();
  }

  void setListStatus(bool isFollowing, bool value) {
    if (!isFollowing) {
      connectionslistStatus.isFollowersPrivate = value;
    } else {
      connectionslistStatus.isFollowingPrivate = value;
    }
  }

  Future<dynamic> getAtsignsList({bool isFollowing = false}) async {
    Completer<dynamic> c = Completer<dynamic>();
    bool isInit = status == null;
    try {
      setStatus(Status.loading);
      await _connectionsService.getAtsignsList(isInit: isInit);
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  Future<dynamic> changeListStatus(bool isFollowing, bool value) async {
    Completer<dynamic> c = Completer<dynamic>();
    try {
      setStatus(Status.loading);
      await _connectionsService.changeListPublicStatus(isFollowing, value);
      setListStatus(isFollowing, value);
      setStatus(Status.done);
      c.complete(true);
    } catch (ex) {
      error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  Future<dynamic> follow(String? atsign) async {
    Completer<dynamic> c = Completer<dynamic>();
    try {
      setStatus(Status.loading);
      Atsign? data = await _connectionsService.follow(atsign);
      if (data != null) {
        followingList!.add(data);
        _modifyFollowersList(atsign, true);
      }
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      error = ex;
      setStatus(Status.error);
    }

    return c.future;
  }

  Future<dynamic> unfollow(String? atsign) async {
    Completer<dynamic> c = Completer<dynamic>();
    try {
      setStatus(Status.loading);
      bool result = await _connectionsService.unfollow(atsign);
      if (result) {
        followingList!.removeWhere((Atsign element) => element.title == atsign);
        _modifyFollowersList(atsign, false);
      }
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  ///deletes [atsign] from followers and following list.
  Future<void> delete(String atsign) async {
    Completer<dynamic> c = Completer<dynamic>();
    try {
      setStatus(Status.loading);
      bool result = await _connectionsService.delete(atsign);
      if (result) {
        followingList!.removeWhere((Atsign element) => element.title == atsign);
        followersList!.removeWhere((Atsign element) => element.title == atsign);
      }
      setStatus(Status.done);
      c.complete(true);
    } catch (e) {
      _logger.severe('deleting $atsign throws $e');
      error = e;
      setStatus(Status.error);
    }
  }

  void _modifyFollowersList(String? atsign, bool follow) {
    int index = followersList!.indexWhere((Atsign element) => element.title == atsign);
    if (index != -1) {
      Atsign data = followersList![index];
      followersList![index] = data..isFollowing = follow;
    }
  }

  bool containsFollowing(String? atsign) {
    int index = followingList!.indexWhere((Atsign data) => data.title == atsign);
    return index != -1;
  }

  ///Returns data with the title = [atsign] from either followers/following list based on [isFollowing].
  Atsign? getData(bool isFollowing, String? atsign) {
    if (isFollowing) {
      return followingList!.firstWhereOrNull(
        (Atsign data) => data.title == atsign,
      );
    }
    return followersList!.firstWhereOrNull(
      (Atsign data) => data.title == atsign,
    );
  }
}

enum Status { getData, loading, done, error }

class ListStatus {
  bool isFollowersPrivate = false;
  bool isFollowingPrivate = false;
}
