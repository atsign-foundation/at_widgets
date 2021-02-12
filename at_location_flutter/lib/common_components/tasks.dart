import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class Tasks extends StatelessWidget {
  final IconData icon;
  final String task;
  final Function onTap;
  Tasks({@required this.task, @required this.icon, @required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44.toHeight,
        //width: 70.toWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              size: 20.toWidth,
              color: AllColors().ORANGE,
            ),
            Flexible(
              child: Text(
                task,
                style: Theme.of(context).primaryTextTheme.headline3,
              ),
            )
          ],
        ),
      ),
    );
  }
}
