import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class InputOTPField extends StatefulWidget {
  final String? pin;
  final Color fillColor;
  final Function(String) onChange;

  const InputOTPField({
    super.key,
    this.pin,
    this.fillColor = ColorConstant.pinFillColor,
    required this.onChange,
  });

  @override
  State<InputOTPField> createState() => _InputOTPFieldState();
}

class _InputOTPFieldState extends State<InputOTPField> {
  List<TextEditingController> listCellController = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    if ((widget.pin ?? '').isNotEmpty && widget.pin?.length == 4) {
      for (int i = 0; i < 4; i++) {
        listCellController[i].text = widget.pin?[i] ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 56,
            child: TextField(
              controller: listCellController[index],
              maxLength: 1,
              maxLines: 1,
              onChanged: (value) {
                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                } else if (value.length == 1) {
                  index < 3
                      ? FocusScope.of(context).nextFocus()
                      : FocusScope.of(context).unfocus();
                }
                widget.onChange.call(
                  listCellController.map((e) => e.text).toList().join(),
                );
              },
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 30,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                fillColor: widget.fillColor,
                counterText: '',
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 16);
        },
      ),
    );
  }
}
