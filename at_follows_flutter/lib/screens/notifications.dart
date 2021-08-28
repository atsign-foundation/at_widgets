import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        appBar: CustomAppBar(),
        body: Padding(
          padding: EdgeInsets.all(16.0.toFont),
          child: Column(
            children: <Widget>[
              Container(
                  height: 70,
                  width: double.infinity,
                  color: ColorConstants.fillColor)
            ],
          ),
        ));
  }
}
