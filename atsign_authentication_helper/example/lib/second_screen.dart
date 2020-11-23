import 'package:flutter/material.dart';
import 'package:atsign_authentication_helper/services/client_sdk_service.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // any logic
          },
          child:
              Text('Welcome ${ClientSdkService.getInstance().currentAtsign}!'),
        ),
      ),
    );
  }
}
