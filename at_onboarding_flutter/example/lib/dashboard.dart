import 'package:at_onboarding_flutter_example/switch_atsign.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Switch @sign',
            onPressed: () async {
              var atSignList = await KeychainUtil.getAtsignList();
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    AtSignBottomSheet(atSignList: atSignList ?? []),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Successfully onboarded to dashboard')),
    );
  }
}
