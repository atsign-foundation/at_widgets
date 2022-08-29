import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:at_theme_flutter/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAtClient extends Mock implements AtClient {}

class MockAtClientManager extends Mock implements AtClientManager {
  static final MockAtClientManager _singleton = MockAtClientManager._internal();

  MockAtClientManager._internal();

  factory MockAtClientManager.getInstance() {
    return _singleton;
  }
}

void main() async {
  // MockAtClientManager mockAtClientManager = MockAtClientManager();

  // AtClientManager atClientManager;

  // setUp(() {
  //   atClientManager = MockAtClientManager();
  // });

  // var atSign = '@alice';
  // atClientManager = AtClientManager(atSign);
  // final preference = AtClientPreference()..syncRegex = '.wavi';
  // AtClient atClient = await AtClientImpl.create(atSign, 'wavi', preference,
  //     atClientManager: atClientManager);

  test("test", () async {
    // atClientManager.setCurrentAtSign(atSign, ".wavi", preference);
    // // print(atClient.getCurrentAtSign());
    // MockAtClientManager().init();
    // print(MockAtClientManager().getInstance().atClient);

    // when(
    //   () => mockAtClientManager.atClient.getCurrentAtSign(),
    // ).thenAnswer(
    //   (invocation) => "@alice",
    // );

    // ThemeService().initThemeService("domain", 69);

    AppTheme theme = AppTheme(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        secondaryColor: Colors.white,
        backgroundColor: Colors.blue);

    var atSign = '@alice🛠';
    // final preference = AtClientPreference()..syncRegex = '.wavi';
    // final atClientManager = await MockAtClientManager.getInstance()
    //     .setCurrentAtSign(atSign, 'wavi', preference);
    // var atClient = atClientManager.atClient;
    // MockAtClientManager.getInstance().
    // MockAtClientManager.getInstance().atClient.put()

    // when(() => MockAtClientManager.getInstance()
    //     .atClient
    //     .put(AtKey()..key = "key", "")).thenAnswer((invocation) async => true);

    // print(MockAtClientManager.getInstance().atClient.getCurrentAtSign());
    // ThemeService().initThemeService("domain", 69);
    // var res = await ThemeService().updateThemeData(theme);

    final preference = AtClientPreference()..syncRegex = '.wavi';
    // final atClientManager = await AtClientManager.getInstance()
    //     .setCurrentAtSign(atSign, 'wavi', preference);
    // var atClient = atClientManager.atClient;

    when(() => AtClientManager.getInstance()
        .atClient
        .put(AtKey()..key = "key", "")).thenAnswer((invocation) async => true);

    print(AtClientManager.getInstance().atClient.getCurrentAtSign());
    ThemeService().initThemeService("domain", 69);
    var res = await ThemeService().updateThemeData(theme);
    // print(res);
  });
}

// class MockAtClientManager extends Mock
//     with MockPlatformInterfaceMixin
//     implements AtClientManager {
//   final preference = AtClientPreference()..syncRegex = '.wavi';

//   late AtClient atClient;

//   void init() async {
//     atClient = await AtClientImpl.create("@alice", "wavi", preference);
//   }

//   @override
//   AtClientManager getInstance() => MockAtClientManager();
// }
