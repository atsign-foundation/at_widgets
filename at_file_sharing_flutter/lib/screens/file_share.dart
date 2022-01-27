import 'package:at_file_sharing_flutter/screens/select_contact/select_contact.dart';
import 'package:flutter/material.dart';
import 'package:at_file_sharing_flutter/utils/at_file_sharing_flutter_utils.dart';

class FileShare extends StatefulWidget {
  const FileShare({Key? key}) : super(key: key);

  @override
  _FileShareState createState() => _FileShareState();
}

class _FileShareState extends State<FileShare> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SingleChildScrollView(
        controller: scrollController,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: 20.toWidth, vertical: 20.toHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SelectContactWidget(),
              ],
            )));
  }
}
