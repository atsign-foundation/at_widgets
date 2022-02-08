// ignore_for_file: implementation_imports, prefer_typing_uninitialized_variables

import 'package:at_client/at_client.dart';
import 'package:at_client/src/service/sync_service_impl.dart';
import 'package:at_sync_ui_flutter/at_sync_ui.dart';
import 'package:flutter/material.dart';

class AtSyncUIService {
  static final AtSyncUIService _singleton = AtSyncUIService._internal();
  AtSyncUIService._internal();

  factory AtSyncUIService() {
    return _singleton;
  }

  Function? onSuccessCallback, onErrorCallback;
  var syncService;

  void init({
    required GlobalKey<NavigatorState> appNavigator,
    Function? onSuccessCallback,
    Function? onErrorCallback,
  }) {
    this.onSuccessCallback = onSuccessCallback;
    this.onErrorCallback = onErrorCallback;
    AtSyncUI.instance.setAppNavigatorKey(appNavigator);

    var _atSyncUIController = AtSyncUIController();
    AtSyncUI.instance.setupController(controller: _atSyncUIController);

    syncService = AtClientManager.getInstance().syncService;
    syncService.setOnDone(_onSuccessCallback);
  }

  Future<void> sync() async {
    assert(syncService != null, "AtSyncUIService not initialised");

    AtSyncUI.instance.showDialog();
    syncService.sync(onDone: _onSuccessCallback);
  }

  Future<void> _onSuccessCallback(SyncResult syncStatus) async {
    AtSyncUI.instance.hideDialog();

    if ((syncStatus.syncStatus == SyncStatus.failure) &&
        (onErrorCallback != null)) {
      onErrorCallback!(syncStatus);
    }

    if (onSuccessCallback != null) {
      onSuccessCallback!(syncStatus);
    }
  }
}
