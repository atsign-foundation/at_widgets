import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  Widget? prefix;
  Widget? suffix;
  String hintText;
  bool isNumpad;
  int? maxLength;
  Function(String) onChange;

  InputField(
      {super.key,
      this.prefix,
      this.suffix,
      required this.onChange,
      this.maxLength,
      this.isNumpad = false,
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
          const SizedBox(width: 5),
          prefix ?? const SizedBox.shrink(),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              maxLength: maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: 1,
              keyboardType: isNumpad ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  counterText: "",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
              onChanged: (String val) {
                onChange(val);
              },
            ),
          ),
          suffix ?? const SizedBox.shrink(),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
