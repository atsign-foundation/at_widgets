import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Function() onTap;
  final bool isSelected;

  const IconButtonWidget({
    Key? key,
    required this.icon,
    this.backgroundColor = Colors.white,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          icon,
          color: isSelected ? AllColors().buttonColor : Colors.black,
          fit: BoxFit.cover,
          package: 'at_contacts_group_flutter',
        ),
      ),
    );
  }
}
