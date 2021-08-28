import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';

/// AtContext is a wrapper class around the widget tree to provide global access
/// to [atClientService] and [atClientPreference] via the BuildContext
class AtContext extends InheritedWidget {
  AtContext({
    Key? key,
    required Widget child,
    required this.atClientService,
    required this.atClientPreference,
  }) : super(key: key, child: child);

  /// The AtClientService exposes a developer friendly abstraction of the @protocol.
  final AtClientService atClientService;

  /// The AtClientImpl is the concrete implementation of the AtClient abstract class.
  AtClientImpl? get atClient => atClientService.atClient;

  /// The AtClientPreference is the developer defined configuration of the AtClientImpl.
  final AtClientPreference atClientPreference;

  /// Get the currently active @sign.
  String? get currentAtSign => atClient?.currentAtSign;

  /// Onboard as another @sign where [atsign] is specified as a string.
  void switchAtsign(String atsign) {
    atClientService.onboard(
      atClientPreference: atClientPreference,
      atsign: atsign,
    );
  }

  /// Calling AtContext.of(context) in the widget tree will provide you with
  /// the nearest instance of AtContext containing all of the getters for this class.
  static AtContext of(BuildContext context) {
    AtContext? atContext = context.dependOnInheritedWidgetOfExactType<AtContext>();
    assert(atContext != null);
    return atContext!;
  }

  @override
  bool updateShouldNotify(AtContext oldWidget) {
    return true;
  }
}
