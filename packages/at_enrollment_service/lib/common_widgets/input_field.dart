import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  Widget? prefix;
  Widget? suffix;
  String hintText;
  Function(String) onChange;

  InputField(
      {super.key,
      this.prefix,
      this.suffix,
      required this.onChange,
      this.hintText = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          prefix ?? const SizedBox.shrink(),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: hintText),
              onChanged: (String val) {
                onChange(val);
              },
            ),
          ),
          suffix ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
