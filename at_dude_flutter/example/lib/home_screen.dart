import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_dude_flutter/dude_theme.dart';
import 'package:at_dude_flutter/screens/send_dude_screen.dart';
import 'package:at_dude_flutter/utils/init_dude_service.dart';
import 'package:flutter/material.dart';
import 'package:at_dude_flutter/at_dude_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Get the AtClientManager instance

class _HomeScreenState extends State<HomeScreen> {
  var atClientManager = AtClientManager.getInstance();
  String? activeAtSign;

  void getAtSignAndInitializeDude() async {
    var currentAtSign = atClientManager.atClient.getCurrentAtSign();
    setState(() {
      activeAtSign = currentAtSign;
      print(activeAtSign);
    });
    initializeDudeService( currentAtSign!,rootPort: 64);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {});
  }

  @override
  void initState() {
    getAtSignAndInitializeDude();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  DudeWidget(
      dudeTheme: DudeTheme.dark(),
    );
  }
}
