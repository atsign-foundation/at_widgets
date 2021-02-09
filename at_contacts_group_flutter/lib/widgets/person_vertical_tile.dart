import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_group_flutter/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class CustomPersonVerticalTile extends StatelessWidget {
  final String imageLocation, title, subTitle;
  final bool isTopRight;
  final IconData icon;
  final Function onCrossPressed;

  CustomPersonVerticalTile(
      {@required this.imageLocation,
      this.title,
      this.subTitle,
      this.isTopRight = false,
      this.icon,
      this.onCrossPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: 60,
                width: 60,
                child: imageLocation != null
                    ? CustomCircleAvatar(
                        size: 60,
                        image: imageLocation,
                      )
                    : ContactInitial(
                        initials: subTitle.substring(1, 3),
                      ),
              ),
              icon != null
                  ? Positioned(
                      top: isTopRight ? 0 : null,
                      bottom: !isTopRight ? 0 : null,
                      right: 0,
                      child: GestureDetector(
                        onTap: onCrossPressed,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          child: Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(height: 2),
          title != null
              ? Text(
                  title,
                  style: CustomTextStyles().grey16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                )
              : SizedBox(),
          SizedBox(height: 2),
          subTitle != null
              ? Text(
                  subTitle,
                  style: CustomTextStyles().grey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
