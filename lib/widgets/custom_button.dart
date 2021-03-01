import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final isActive;
  final text;
  final highLightColor;
  final providerStatus;
  final double width;
  final Function onPressedCallBack;
  // final highlightColor;
  CustomButton(
      {@required this.text,
      @required this.onPressedCallBack,
      this.providerStatus,
      textstyle,
      highLightColor,
      this.width = 0.0,
      this.isActive = false})
      : this.highLightColor = highLightColor ?? ColorConstants.secondary;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  // bool isActive = false;

  @override
  void initState() {
    // this.isActive = widget.isActive;
    super.initState();
  }

  ConnectionProvider connectionProvider = ConnectionProvider();

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        minWidth: widget.width,
        onPressed: () {
          // print("pressed highlight color is ${widget.highLightColor}");
          // if (widget.providerStatus != null) {
          //   connectionProvider.setStatus(widget.providerStatus);
          // }
          widget.onPressedCallBack(!widget.isActive);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0.toFont),
            side: BorderSide(color: ColorConstants.borderColor)),
        color: widget.isActive
            ? ColorConstants.buttonHighLightColor
            : ColorConstants.secondary,
        highlightColor: widget.highLightColor,
        child: Text(
          widget.text,
          style: widget.isActive
              ? CustomTextStyles.fontR14light
              : CustomTextStyles.fontR14primary,
        ));
  }
}
