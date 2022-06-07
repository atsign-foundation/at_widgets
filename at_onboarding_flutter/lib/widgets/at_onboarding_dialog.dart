import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/material.dart';

class AtOnboardingDialog extends StatefulWidget {
  static Future showError({
    required BuildContext context,
    String? title,
    required String message,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AtOnboardingDialog(
            title: title ?? 'Error',
            message: message,
            actions: [
              AtOnboardingSecondaryButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                  onCancel?.call();
                },
              ),
            ],
          );
        });
  }

  final String title;
  final String message;
  final List<Widget> actions;

  const AtOnboardingDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.actions,
  }) : super(key: key);

  @override
  State<AtOnboardingDialog> createState() => _AtOnboardingDialogState();
}

class _AtOnboardingDialogState extends State<AtOnboardingDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.message),
      actions: widget.actions,
    );
  }
}
