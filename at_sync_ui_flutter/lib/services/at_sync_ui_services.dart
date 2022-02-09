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
  AtSyncUIStyle atSyncUIStyle = AtSyncUIStyle.cupertino;
  AtSyncUIOverlay atSyncUIOverlay = AtSyncUIOverlay.dialog;
  bool showTextWhileSyncing = true;

  void init({
    required GlobalKey<NavigatorState> appNavigator,
    AtSyncUIStyle? atSyncUIStyle,
    AtSyncUIOverlay? atSyncUIOverlay,
    Function? onSuccessCallback,
    Function? onErrorCallback,
    Color? primaryColor,
    Color? backgroundColor,
    Color? labelColor,
    AtSyncUIStyle? style,
    bool? showTextWhileSyncing,
    bool? isSnackbarOverlay,
  }) {
    this.onSuccessCallback = onSuccessCallback;
    this.onErrorCallback = onErrorCallback;
    AtSyncUI.instance.setAppNavigatorKey(appNavigator);
    if (isSnackbarOverlay != null) {
      AtSyncUI.instance.setSnackbarType(isSnackbarOverlay);
    }
    if (atSyncUIStyle != null) {
      this.atSyncUIStyle = atSyncUIStyle;
    }
    if (atSyncUIOverlay != null) {
      this.atSyncUIOverlay = atSyncUIOverlay;
    }
    this.showTextWhileSyncing = showTextWhileSyncing ?? true;

    AtSyncUI.instance.configTheme(
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      labelColor: labelColor,
      style: style,
    );

    var _atSyncUIController = AtSyncUIController();
    AtSyncUI.instance.setupController(controller: _atSyncUIController);

    syncService = AtClientManager.getInstance().syncService;
    syncService.setOnDone(_onSuccessCallback);
  }

  Future<void> sync() async {
    assert(syncService != null, "AtSyncUIService not initialised");

    _show();
    syncService.sync(onDone: _onSuccessCallback);
  }

  Future<void> _onSuccessCallback(SyncResult syncStatus) async {
    _hide();

    if ((syncStatus.syncStatus == SyncStatus.failure) &&
        (onErrorCallback != null)) {
      onErrorCallback!(syncStatus);
    }

    if (onSuccessCallback != null) {
      onSuccessCallback!(syncStatus);
    }
  }

  void _show() {
    if (atSyncUIOverlay == AtSyncUIOverlay.dialog) {
      AtSyncUI.instance.showDialog(
          message: showTextWhileSyncing ? 'Sync in progress' : null);
      return;
    }

    AtSyncUI.instance.showSnackBar(
        message: showTextWhileSyncing ? 'Sync in progress' : null);
  }

  void _hide() {
    if (atSyncUIOverlay == AtSyncUIOverlay.dialog) {
      AtSyncUI.instance.hideDialog();
      return;
    }

    AtSyncUI.instance.hideSnackBar();
  }
}
