import 'dart:collection';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_sync_ui_flutter/services/switch_atsign.dart';
import 'package:flutter/material.dart';

import 'at_sync_cupertino.dart' as cupertino;
import 'at_sync_material.dart' as material;

enum AtSyncUIStyle {
  material,
  cupertino,
}

enum AtSyncUIOverlay {
  dialog,
  snackbar,
}

AtSyncUIStyle _kDefaultStyle = AtSyncUIStyle.cupertino;
Color _kDefaultPrimaryColor = const Color(0xFFf4533d);
Color _kDefaultBackgroundColor = const Color(0xFFFFFFFF);
Color _kDefaultLabelColor = const Color(0xFF000000);

class AtSyncUIController {
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  final Queue<String> _loadingQueue = Queue<String>();

  void addLoadingQueue() {
    _loadingQueue.add("loading");
    if (_loadingQueue.isNotEmpty && loading.value == false) {
      loading.value = true;
    }
  }

  void removeLoadingQueue() {
    _loadingQueue.removeFirst();
    if (_loadingQueue.isEmpty && loading.value == true) {
      loading.value = false;
    }
  }

  void clearLoadingQueue() {
    _loadingQueue.clear();
    if (_loadingQueue.isEmpty && loading.value == false) {
      loading.value = false;
    }
  }

  void dispose() {
    loading.value = false;
    loading.dispose();
    _loadingQueue.clear();
  }
}

class AtSyncUI {
  AtSyncUI._();

  GlobalKey<NavigatorState>? appNavigatorKey;

  static final AtSyncUI _instance = AtSyncUI._();

  static AtSyncUI get instance => _instance;

  AtSyncUIController? _syncUIController;

  AtSyncUIController? get syncUIController => _syncUIController;

  bool _showSwitchAtsignButton = true;
  AtClientPreference? atClientPreference;
  Function? onboardSuccessCallback;

  ///Config
  AtSyncUIStyle _style = AtSyncUIStyle.cupertino;
  Color _primaryColor = _kDefaultPrimaryColor;
  Color _backgroundColor = _kDefaultBackgroundColor;
  Color _labelColor = _kDefaultLabelColor;

  /// Sync Fullscreen
  OverlayEntry? loadingOverlayEntry;
  OverlayEntry? dialogOverlayEntry;
  OverlayEntry? snackBarOverlayEntry;

  /// It set [GlobalKey<NavigatorState>] to get [OverlayState] which use to add  [OverlayEntry]
  void setAppNavigatorKey(GlobalKey<NavigatorState>? appNavigator) {
    appNavigatorKey = appNavigator;
  }

  void setSwitchAtsignButtonMode(
    bool showSwitchAtsignButton, {
    AtClientPreference? atClientPreference,
    Function? onboardSuccessCallback,
  }) {
    _showSwitchAtsignButton = showSwitchAtsignButton;

    this.atClientPreference = atClientPreference;
    this.onboardSuccessCallback = onboardSuccessCallback;
  }

  /// Provide default theme for UI (dialog/snackBar ...) using in the app
  void configTheme({
    Color? primaryColor,
    Color? backgroundColor,
    Color? labelColor,
    AtSyncUIStyle? style,
  }) {
    _primaryColor = primaryColor ?? _kDefaultPrimaryColor;
    _backgroundColor = backgroundColor ?? _kDefaultBackgroundColor;
    _labelColor = labelColor ?? _kDefaultLabelColor;
    _style = style ?? _kDefaultStyle;
  }

  void setupController({required AtSyncUIController controller}) {
    if (_syncUIController != null) {
      _syncUIController?.dispose();
      _syncUIController = null;
    }
    _syncUIController = controller;
    _syncUIController?.loading.addListener(() {
      if (_syncUIController?.loading.value == true) {
        showDialog();
      } else {
        hideDialog();
      }
    });
  }

  /// Show dialog UI
  void showDialog({String? message}) {
    assert(appNavigatorKey != null, "Must set appNavigator before show dialog");
    assert(appNavigatorKey!.currentState?.overlay != null,
        "Cannot get current context");
    if (dialogOverlayEntry != null) {
      hideDialog();
    }
    dialogOverlayEntry = _buildDialogOverlayEntry(
      primaryColors: _primaryColor,
      backgroundColor: _backgroundColor,
      labelColor: _labelColor,
      style: _style,
      message: message,
      showSwitchAtsignButton: _showSwitchAtsignButton,
    );
    appNavigatorKey?.currentState?.overlay?.insert(dialogOverlayEntry!);
  }

  /// Hide dialog UI
  void hideDialog() {
    dialogOverlayEntry?.remove();
    dialogOverlayEntry = null;
  }

  /// Show SnackBar UI
  void showSnackBar({String? message}) {
    assert(appNavigatorKey != null, "Must set appNavigator before show dialog");
    assert(appNavigatorKey!.currentState?.overlay != null,
        "Cannot get current context");

    if (snackBarOverlayEntry != null) {
      hideSnackBar();
    }
    snackBarOverlayEntry = _buildSnackBarOverlayEntry(
      primaryColors: _primaryColor,
      backgroundColor: _backgroundColor,
      labelColor: _labelColor,
      style: _style,
      message: message,
    );
    appNavigatorKey?.currentState?.overlay?.insert(snackBarOverlayEntry!);
  }

  /// Hide SnackBar UI
  void hideSnackBar() {
    snackBarOverlayEntry?.remove();
    snackBarOverlayEntry = null;
  }

  /// Build dialog OverlayEntry
  /// Display fullscreen with 50% opacity and can't interact
  /// [AtSyncIndicator] place in center of screen
  OverlayEntry _buildDialogOverlayEntry({
    Color? primaryColors,
    Color? backgroundColor,
    Color? labelColor,
    AtSyncUIStyle? style,
    String? message,
    required bool showSwitchAtsignButton,
  }) {
    return OverlayEntry(builder: (context) {
      // You can return any widget you like here
      // to be displayed on the Overlay
      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  style == AtSyncUIStyle.cupertino
                      ? cupertino.AtSyncIndicator(
                          color: primaryColors,
                          radius: 24,
                        )
                      : material.AtSyncIndicator(
                          color: primaryColors,
                          radius: 24,
                        ),
                  if ((message ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 0),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          message ?? '',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  showSwitchAtsignButton
                      ? TextButton(
                          onPressed: () {
                            if (atClientPreference != null &&
                                onboardSuccessCallback != null) {
                              hideDialog();
                              SwitchAtsignService().switchAtsign(
                                  atClientPreference: atClientPreference!,
                                  onboardSuccessCallback:
                                      onboardSuccessCallback!);
                            }
                          },
                          child: const Text(
                            'Switch Atsign',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Build snackBar OverlayEntry
  /// Display fullscreen with 50% opacity and can't interact
  /// [AtSyncIndicator] place in bottomCenter of screen
  static OverlayEntry _buildSnackBarOverlayEntry({
    Color? primaryColors,
    Color? backgroundColor,
    Color? labelColor,
    AtSyncUIStyle? style,
    String? message,
  }) {
    return OverlayEntry(builder: (context) {
      // You can return any widget you like here
      // to be displayed on the Overlay
      final size = MediaQuery.of(context).size;
      return Positioned(
        width: size.width,
        height: 100,
        bottom: 0,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: _snackbarUI(
            context,
            primaryColors,
            backgroundColor,
            labelColor,
            style,
            message,
          ),
        ),
      );
    });
  }

  static Widget _snackbarUI(
    BuildContext context,
    Color? primaryColors,
    Color? backgroundColor,
    Color? labelColor,
    AtSyncUIStyle? style,
    String? message,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          style == AtSyncUIStyle.cupertino
              ? cupertino.AtSyncIndicator(
                  color: primaryColors,
                  radius: 12,
                )
              : material.AtSyncIndicator(
                  color: primaryColors,
                  radius: 12,
                ),
          if ((message ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 68),
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  message ?? '',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
