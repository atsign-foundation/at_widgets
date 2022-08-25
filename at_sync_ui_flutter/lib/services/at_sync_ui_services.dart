// ignore_for_file: implementation_imports, prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:at_client/src/service/sync_service.dart';
import 'package:at_client/at_client.dart';
import 'package:at_sync_ui_flutter/at_sync_ui.dart';
import 'package:flutter/material.dart';
import 'package:at_client/src/listener/sync_progress_listener.dart';

class AtSyncUIService extends SyncProgressListener {
  static final AtSyncUIService _singleton = AtSyncUIService._internal();
  AtSyncUIService._internal();

  factory AtSyncUIService() {
    return _singleton;
  }

  @override
  void onSyncProgressEvent(SyncProgress syncProgress) {
    if (AtSyncUIService().syncProgressCallback != null) {
      AtSyncUIService().syncProgressCallback!(syncProgress);
    }

    if (syncProgress.syncStatus == SyncStatus.success) {
      _hide();
      _atSyncUIListenerSink.add(AtSyncUIStatus.completed);
    }

    if (syncProgress.syncStatus == SyncStatus.failure) {
      _atSyncUIListenerSink.add(AtSyncUIStatus.failed);
    }
  }

  Function? onSuccessCallback, onErrorCallback, syncProgressCallback;
  late SyncService syncService;
  AtSyncUIStyle atSyncUIStyle = AtSyncUIStyle.cupertino;
  AtSyncUIOverlay atSyncUIOverlay = AtSyncUIOverlay.none;
  bool showTextWhileSyncing = true;

  final StreamController _atSyncUIListenerController =
      StreamController<AtSyncUIStatus>.broadcast();

  /// [atSyncUIListener] can be used to listen to sync status changes
  Stream<AtSyncUIStatus> get atSyncUIListener =>
      _atSyncUIListenerController.stream as Stream<AtSyncUIStatus>;
  StreamSink<AtSyncUIStatus> get _atSyncUIListenerSink =>
      _atSyncUIListenerController.sink as StreamSink<AtSyncUIStatus>;

  /// [appNavigator] is used for navigation purpose
  /// [atSyncUIOverlay] decides whether dialog or snackbar to be shown while syncing
  /// [style] if material or cupertino style to be applied
  /// [showTextWhileSyncing] should text be shown while syncing
  /// [onSuccessCallback] called after successful sync
  /// [onErrorCallback] called after failure in sync
  /// [syncProgressCallback] Notifies the registered listener for the [SyncProgress]
  /// [primaryColor],[backgroundColor], [labelColor] will be used while displaying overlay/snackbar.
  void init({
    required GlobalKey<NavigatorState> appNavigator,
    AtSyncUIOverlay? atSyncUIOverlay,
    AtSyncUIStyle? style,
    bool? showTextWhileSyncing,
    Function? onSuccessCallback,
    Function? onErrorCallback,
    Function? syncProgressCallback,
    Color? primaryColor,
    Color? backgroundColor,
    Color? labelColor,
  }) {
    this.onSuccessCallback = onSuccessCallback;
    this.onErrorCallback = onErrorCallback;
    this.syncProgressCallback = syncProgressCallback;
    AtSyncUI.instance.setAppNavigatorKey(appNavigator);

    /// change status to notStarted
    _atSyncUIListenerSink.add(AtSyncUIStatus.notStarted);

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
    syncService.addProgressListener(this);
    syncService.setOnDone(_onSuccessCallback);
  }

  /// calls sync and shows selected UI
  /// [atSyncUIOverlay] decides whether dialog or snackbar to be shown while syncing
  void sync({AtSyncUIOverlay atSyncUIOverlay = AtSyncUIOverlay.none}) {
    this.atSyncUIOverlay = atSyncUIOverlay;

    /// change status to syncing
    _atSyncUIListenerSink.add(AtSyncUIStatus.syncing);

    _show(atSyncUIOverlay: atSyncUIOverlay);

    syncService.sync(onDone: _onSuccessCallback);
  }

  void _onSuccessCallback(SyncResult syncStatus) {
    if ((syncStatus.syncStatus == SyncStatus.failure) &&
        (onErrorCallback != null)) {
      onErrorCallback!(syncStatus);
    }

    if (onSuccessCallback != null) {
      onSuccessCallback!(syncStatus);
    }
  }

  void _show({AtSyncUIOverlay? atSyncUIOverlay}) {
    if ((atSyncUIOverlay ?? this.atSyncUIOverlay) == AtSyncUIOverlay.none) {
      return;
    }

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
    if (atSyncUIOverlay == AtSyncUIOverlay.none) {
      return;
    }

    if (atSyncUIOverlay == AtSyncUIOverlay.dialog) {
      AtSyncUI.instance.hideDialog();
      return;
    }

    AtSyncUI.instance.hideSnackBar();
  }
}

///Enum to represent the sync status for AtSyncUIFlutter
enum AtSyncUIStatus { syncing, completed, failed, notStarted }
