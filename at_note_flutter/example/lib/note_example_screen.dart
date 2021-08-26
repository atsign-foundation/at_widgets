import 'dart:math';

import 'package:at_note_flutter_example/constants.dart';
import 'package:at_note_flutter/utils/init_note_service.dart';
import 'package:at_note_flutter/screens/note_list_screen.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';

class NoteExampleScreen extends StatefulWidget {
  @override
  _NoteExampleScreenState createState() => _NoteExampleScreenState();
}

class _NoteExampleScreenState extends State<NoteExampleScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;

  @override
  void initState() {
    getAtSignAndInitializeNote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Note Example'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome $activeAtSign',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: () async {
                    print('activeAtSign = $activeAtSign');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteListScreen(
                          activeAtSign!,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Show Note List Screen',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getAtSignAndInitializeNote() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeNoteService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
