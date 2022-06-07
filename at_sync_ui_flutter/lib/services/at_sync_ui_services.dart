// ignore_for_file: implementation_imports, prefer_typing_uninitialized_variables

import 'package:at_client/at_client.dart';
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

  /// [appNavigator] is used for navigation purpose
  /// [atSyncUIOverlay] decides whether dialog or snackbar to be shown while syncing
  /// [style] if material or cupertino style to be applied
  /// [showTextWhileSyncing] should text be shown while syncing
  /// [onSuccessCallback] called after successful sync
  /// [onErrorCallback] called after failure in sync
  /// [primaryColor],[backgroundColor], [labelColor] will be used while displaying overlay/snackbar.
  void init({
    required GlobalKey<NavigatorState> appNavigator,
    AtSyncUIOverlay? atSyncUIOverlay,
    AtSyncUIStyle? style,
    bool? showTextWhileSyncing,
    Function? onSuccessCallback,
    Function? onErrorCallback,
    Color? primaryColor,
    Color? backgroundColor,
    Color? labelColor,
  }) {
    this.onSuccessCallback = onSuccessCallback;
    this.onErrorCallback = onErrorCallback;
    AtSyncUI.instance.setAppNavigatorKey(appNavigator);

    if (style != null) {
      atSyncUIStyle = style;
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

  /// calls sync and shows selected UI
  /// [atSyncUIOverlay] decides whether dialog or snackbar to be shown while syncing
  Future<void> sync({AtSyncUIOverlay? atSyncUIOverlay}) async {
    assert(syncService != null, "AtSyncUIService not initialised");

    if (atSyncUIOverlay != null) {
      this.atSyncUIOverlay = atSyncUIOverlay;
    }

    _show(atSyncUIOverlay: atSyncUIOverlay);
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

  void _show({AtSyncUIOverlay? atSyncUIOverlay}) {
    if ((atSyncUIOverlay ?? this.atSyncUIOverlay) == AtSyncUIOverlay.dialog) {
      AtSyncUI.instance.showDialog(
        message: showTextWhileSyncing ? 'Sync in progress' : null,
      );
      return;
    }

    AtSyncUI.instance.showSnackBar(
      message: showTextWhileSyncing ? 'Sync in progress' : null,
    );
  }

  void _hide() {
    if (atSyncUIOverlay == AtSyncUIOverlay.dialog) {
      AtSyncUI.instance.hideDialog();
      return;
    }

    AtSyncUI.instance.hideSnackBar();
  }
}
