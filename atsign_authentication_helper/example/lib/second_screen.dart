import 'package:flutter/material.dart';
import 'package:atsign_authentication_helper_example/client_sdk_service.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign;
  @override
  void initState() {
    getAtSign();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // any logic
          },
          child: Text('Welcome $activeAtSign!'),
        ),
      ),
    );
  }

  void getAtSign() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
  }
}
