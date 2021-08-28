import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String error;
  CustomErrorDialog({required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Text(
            Strings.error,
            style: CustomTextStyles.fontR14primary,
          ),
          const Icon(Icons.sentiment_dissatisfied)
        ],
      ),
      content: Text(error),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(Strings.close),
        )
      ],
    );
  }
}

class ErrorDialog {
  static final ErrorDialog _singleton = ErrorDialog._internal();

  ErrorDialog._internal();
  // final AtSignLogger _logger = AtSignLogger('ErrorDialog');

  factory ErrorDialog.getInstance() {
    return _singleton;
  }

  void show(String error, {required BuildContext context}) {
    showDialog(
        context: context,
        builder: (_) {
          return CustomErrorDialog(
            error: error.toString(),
          );
        });
  }
}
