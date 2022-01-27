import 'package:at_file_sharing_flutter/utils/at_file_sharing_flutter_utils.dart';
import 'package:flutter/material.dart';

class SelectContactWidget extends StatefulWidget {
  const SelectContactWidget({Key? key}) : super(key: key);

  //final Function(bool) onUpdate;
  // final String contactIcon;
  // SelectContactWidget(this.contactIcon);
  @override
  _SelectContactWidgetState createState() => _SelectContactWidgetState();
}

class _SelectContactWidgetState extends State<SelectContactWidget> {
  String? headerText;

  @override
  void initState() {
    headerText = TextStrings().welcomeContactPlaceholder;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        textTheme: const TextTheme(
          subtitle1: TextStyle(
            color: ColorConstants.inputFieldColor,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.toFont),
        child: Container(
            color: ColorConstants.inputFieldColor,
            child: _ExpansionTileWidget(
              headerText!,
              (index) {
                // widget.onUpdate(true);
                setState(() {});
              },
            )),
      ),
    );
  }
}

class _ExpansionTileWidget extends StatelessWidget {
  final String headerText;
  final Function(int) onSelected;
  const _ExpansionTileWidget(this.headerText, this.onSelected);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: SizeConfig().isTablet(context)
          ? EdgeInsets.symmetric(vertical: 10.toFont, horizontal: 10.toFont)
          : EdgeInsets.only(left: 10.toFont, right: 10.toFont),
      backgroundColor: ColorConstants.inputFieldColor,
      title: Text(
        headerText,
        style: TextStyle(
          color: ColorConstants.fadedText,
          fontSize: 14.toFont,
        ),
      ),
      trailing: InkWell(
        onTap: () async {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: const Icon(Icons.account_circle_rounded,color: Colors.black)
        ),
      ),
    );
  }
}
