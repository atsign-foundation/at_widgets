import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';

import '../../at_app_flutter.dart';

/// AtContext is a wrapper class around the widget tree to provide global access
/// to [atClientService] and [atClientPreference] via the BuildContext
class AtContext extends InheritedWidget {
  AtContext({Key? key, required Widget child, required this.atClientPreference})
      : super(key: key, child: child);

  /// The AtClientManager is the abstraction over the at_client sdk
  /// This is used to instantiate services on a per atsign basis
  final AtClientManager atClientManager = AtClientManager.getInstance();

  /// The AtClientImpl is an implementation of the AtClient Interface
  /// This is the primary class developers will use to:
  /// - Call @protocol verbs
  /// - Monitor for notifications
  /// - Persist their keys
  AtClient get atClient => atClientManager.atClient;

  /// The AtClientPreference is the developer defined configuration of the AtClient.
  final AtClientPreference atClientPreference;

  /// Get the currently active @sign.
  String? get currentAtSign => atClient.getCurrentAtSign();

  /// Onboard as another @sign where [atsign] is specified as a string.
  /// You may also override [namespace] and [preference] with your own values.
  void setCurrentAtSign(String atsign,
      {String? namespace, AtClientPreference? preference}) {
    atClientManager.setCurrentAtSign(
      atsign,
      namespace ?? AtEnv.appNamespace,
      preference ?? atClientPreference,
    );
  }

  /// Calling AtContext.of(context) in the widget tree will provide you with
  /// the nearest instance of AtContext containing all of the getters for this class.
  static AtContext of(BuildContext context) {
    var atContext = context.dependOnInheritedWidgetOfExactType<AtContext>();
    assert(atContext != null);
    return atContext!;
  }

  @override
  bool updateShouldNotify(AtContext oldWidget) {
    return true;
  }
}
