import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

enum AccessType { readOnly, readAndWrite }

extension AccessTypeExtension on AccessType {
  String get title {
    switch (this) {
      case AccessType.readOnly:
        return 'Read Only';
      case AccessType.readAndWrite:
        return 'Read & Write';
    }
  }

  String get description {
    switch (this) {
      case AccessType.readOnly:
        return 'You will only be able to view existing information';
      case AccessType.readAndWrite:
        return 'You will be able to add and view information';
    }
  }
}

class TypeSelectionWidget extends StatelessWidget {
  final bool isSelected;
  final AccessType accessType;
  final Function(AccessType) onSelect;

  const TypeSelectionWidget({
    super.key,
    required this.isSelected,
    required this.accessType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelect.call(accessType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        decoration: BoxDecoration(
          color:
              isSelected ? ColorConstant.selectedBackgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(41),
          border: isSelected
              ? Border.all(
                  color: ColorConstant.orange,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              accessType.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              accessType.description,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
