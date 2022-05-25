import 'dart:typed_data';


import 'package:at_dude_flutter/dude_theme.dart';
import 'package:at_dude_flutter/screens/profile_screen.dart';
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:flutter/material.dart';


class AtsignAvatar extends StatefulWidget {
  const AtsignAvatar({Key? key}) : super(key: key);

  @override
  State<AtsignAvatar> createState() => _AtsignAvatarState();
}

class _AtsignAvatarState extends State<AtsignAvatar> {
  late DudeService _dudeService;
  Uint8List? image;
  String? profileName;
  @override
  void initState() {
    _dudeService = DudeService();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await _dudeService
          .getCurrentAtsignContactDetails()
          .then((value) {
        image = value['image'];
        profileName = value['name'];
      });
      profileName ??=  _dudeService.atClientManager.atClient.getCurrentAtSign();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: kPrimaryColor,
        child: image == null
            ? const Icon(
                Icons.person_outline,
              )
            : ClipOval(child: Image.memory(image!)),
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(ProfileScreen.routeName, arguments: profileName);
      },
    );
  }
}
