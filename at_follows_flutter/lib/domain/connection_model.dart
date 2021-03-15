import 'dart:async';
import 'dart:collection';

import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionModel extends ChangeNotifier {
  final List<Atsign> _atsigns = [];

  /// An unmodifiable view of the items in the atsigns.
  UnmodifiableListView<Atsign> get items => UnmodifiableListView(_atsigns);

  void follow(Atsign atsign) {
    print('follow atsign is ${atsign.title}');
  }

  void unfollow(Atsign atsign) {
    print('unfollowin atsign is ${atsign.title}');
  }
}

class ConnectionProvider extends ChangeNotifier {
  static final _singleton = ConnectionProvider._internal();
  ConnectionProvider._internal();

  factory ConnectionProvider() {
    return _singleton;
  }
  // ConnectionProvider({this.status});
  List<Atsign> followersList;
  List<Atsign> followingList;
  List<Atsign> atsignsList;
  // Map<String, Status> status;
  Status status;
  var error;

  ConnectionsService _connectionsService;
  bool _disposed;
  ListStatus connectionslistStatus;

  @override
  void dispose() {
    _disposed = true;
    // Provider.of<ConnectionProvider>(context, listen: false).close;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  init() {
    this.followersList = [];
    this.followingList = [];
    this.atsignsList = [];
    _connectionsService = ConnectionsService();
    connectionslistStatus = ListStatus();
    _disposed = false;
    this.setStatus(null);
  }

  setStatus(Status value) {
    status = value;
    notifyListeners();
  }

  setListStatus(bool isFollowing, bool value) {
    if (!isFollowing) {
      connectionslistStatus.isFollowersPrivate = value;
    } else {
      connectionslistStatus.isFollowingPrivate = value;
    }
    // notifyListeners();
  }

  Future getAtsignsList({bool isFollowing = false}) async {
    Completer c = Completer();

    try {
      setStatus(Status.loading);
      if (isFollowing) {
        followingList = followingList.isEmpty
            ? await _connectionsService.getAtsignsList(isFollowing: isFollowing)
            : followingList;
        atsignsList = followingList;
      } else {
        followersList = followersList.isEmpty
            ? await _connectionsService.getAtsignsList(isFollowing: isFollowing)
            : followersList;
        atsignsList = followersList;
      }
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      this.error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      this.error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  Future changeListStatus(bool isFollowing, bool value) async {
    Completer c = Completer();
    try {
      setStatus(Status.loading);
      await _connectionsService.changeListPublicStatus(isFollowing, value);
      setListStatus(isFollowing, value);
      setStatus(Status.done);
      c.complete(true);
    } catch (ex) {
      this.error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  Future follow(String atsign) async {
    Completer c = Completer();
    try {
      setStatus(Status.loading);
      var data = await _connectionsService.follow(atsign);
      if (data != null) {
        followingList.add(data);
        _modifyFollowersList(atsign, true);
      }
      // atsignsList.add(data);
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      this.error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      this.error = ex;
      setStatus(Status.error);
    }

    return c.future;
  }

  Future unfollow(String atsign) async {
    Completer c = Completer();
    try {
      setStatus(Status.loading);
      var result = await _connectionsService.unfollow(atsign);
      if (result) {
        followingList.removeWhere((element) => element.title == atsign);
        _modifyFollowersList(atsign, false);
      }
      // atsignsList.removeWhere((element) => element.title == atsign);
      setStatus(Status.done);
      c.complete(true);
    } on Error catch (err) {
      this.error = err;
      setStatus(Status.error);
    } on Exception catch (ex) {
      this.error = ex;
      setStatus(Status.error);
    }
    return c.future;
  }

  _modifyFollowersList(String atsign, bool follow) {
    var index = followersList.indexWhere((element) => element.title == atsign);
    var data = followersList[index];
    followersList[index] = data..isFollowing = follow;
  }

  bool containsFollowing(String atsign) {
    var index = this.followingList.indexWhere((data) => data.title == atsign);
    return index != -1;
    // return this.followingList.contains((data) => data.title == atsign);
  }
}

enum Status { getData, loading, done, error }

class ListStatus {
  bool isFollowersPrivate = false;
  bool isFollowingPrivate = false;
}
