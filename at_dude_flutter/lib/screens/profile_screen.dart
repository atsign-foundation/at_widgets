import 'package:at_dude_flutter/models/profile_model.dart';
import 'package:at_dude_flutter/screens/history_screen.dart';
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:at_dude_flutter/widgets/profile_stat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DudeService _dudeService;
  ProfileModel profileModel = ProfileModel.newDude();
  @override
  void initState() {
    _dudeService = DudeService();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      profileModel = await _dudeService.getProfile();
      // profileName ??= DudeService.getInstance().atClient!.getCurrentAtSign();
    });
    super.initState();
  }

  // final ProfileModel profileModel;
  @override
  Widget build(BuildContext context) {
   Provider.of<DudeService>(context).dudes.length;
    final String profileName =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(profileName),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .popAndPushNamed(HistoryScreen.routeName);
                },
                child: const Icon(
                  Icons.history_outlined,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello Dude',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const Text('Your Stats'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfileStat(stat: '${profileModel.dudesSent} Dudes sent'),
                  ProfileStat(
                      stat:
                          '${profileModel.dudeHours.inMinutes} Minutes duding'),
                  ProfileStat(
                      stat:
                          '${profileModel.longestDude.inMinutes} Minute longest dude'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
