import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_follows_flutter/domain/at_follows_list.dart';
import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';

class AtFollowServices {
  AtFollowServices._();
  static final AtFollowServices _instance = AtFollowServices._();
  factory AtFollowServices() => _instance;
  bool isDataFetched = false;
  var _connectionService = ConnectionsService();
  ConnectionProvider _connectionProvider = ConnectionProvider();

  Future initializeFollowService(
      AtClientService atClientserviceInstance) async {
    _connectionService.init(atClientserviceInstance.atClient!.currentAtSign!);
    _connectionProvider.init(atClientserviceInstance.atClient!.currentAtSign!);
    SDKService().setClientService = atClientserviceInstance;
    await _connectionService.getAtsignsList();
    _connectionService.startMonitor();
  }

  AtFollowsList? getFollowersList() {
    return _connectionService.followers;
  }

  AtFollowsList? getFollowingList() {
    return _connectionService.following;
  }

  Future unfollow(String atsign) async {
    return await _connectionProvider.unfollow(atsign);
  }

  Future follow(String atsign) async {
    return await _connectionProvider.follow(atsign);
  }

  Future<bool> removeFollower(String atsign) async {
    return await _connectionService.removeFollower(atsign);
  }
}
