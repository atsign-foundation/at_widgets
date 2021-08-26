import 'package:flutter/material.dart';

/// Bottom Sheet Dialog with 2 options Get Photos from Gallery or Camera
class BottomSheetDialog extends StatefulWidget {
  final Function()? photoCallback;
  final Function()? cameraCallback;

  const BottomSheetDialog({
    Key? key,
    this.photoCallback,
    this.cameraCallback,
  }) : super(key: key);

  @override
  _BottomSheetDialogState createState() => _BottomSheetDialogState();
}

class _BottomSheetDialogState extends State<BottomSheetDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            if (widget.photoCallback != null) {
              widget.photoCallback!();
            }
          },
          child: Container(
            width: 240,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
              border: Border.all(color: Colors.grey.shade50),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                'Gallery',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            if (widget.cameraCallback != null) {
              widget.cameraCallback!();
            }
          },
          child: Container(
            width: 240,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
              border: Border.all(color: Colors.grey.shade50),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                'Camera',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
