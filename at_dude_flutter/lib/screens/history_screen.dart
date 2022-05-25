
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:at_dude_flutter/widgets/atsign_avatar.dart';
import 'package:at_dude_flutter/widgets/dude_bottom_navigation_bar.dart';
import 'package:at_dude_flutter/widgets/dude_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dude_model.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = 'history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DudeService _dudeService;
  List<DudeModel>? dudes;
  @override
  void initState() {
    _dudeService = DudeService();
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback(
    //     (_) async => DudeService.getInstance().getDudes().then((value) {
    //           value.sort((a, b) => b.timeSent.compareTo(a.timeSent));

    //           dudes = value;
    //           setState(() {});
    //         }));
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<DudeService>(context).getDudesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: const [AtsignAvatar()],
      ),
      body: Consumer<DudeService>(
        builder: ((context, _dudeService, child) =>
        _dudeService.dudes.isEmpty
                ? const Center(child: Text('No dudes available'))
                : ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: _dudeService.dudes.length,
                    itemBuilder: (context, index) {
                      return DudeBubble(dude: _dudeService.dudes[index]);
                    })),
      ),
    );
  }
}
