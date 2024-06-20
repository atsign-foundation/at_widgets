import 'package:at_client/at_client.dart';
import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

/// This class contains screen related to setting the SPP (Semi Permanent Pass-code).
class CreatePin extends StatefulWidget {
  const CreatePin({super.key});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  // List of nodes to hold the 6 character SPP
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      height: 450,
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Create a PIN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          'Create a memorable PIN to use when onboarding your atSign in other apps.',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const Text(
          'PIN is used to prevent authentication spam',
          style: TextStyle(fontSize: 13, color: ColorConstant.lightGrey),
        ),
        const SizedBox(height: 50),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => _buildOTPTextField(index))),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              buttonText: 'Save',
              buttonColor: Colors.orange,
              titleStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              onPressed: _saveOTP,
            )
          ],
        ),
      ])),
    );
  }

  Widget _buildOTPTextField(int index) {
    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        focusNode: _focusNodes[index],
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) => _onDigitEntered(index, value),
        decoration: const InputDecoration(
          counterText: '', // Hide the counter
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index].unfocus();
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Process the OTP
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  _saveOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();
    var res;
    try {
      res = await AtClientManager.getInstance().atClient.setSPP(otp);
    } on InvalidPinException catch (e) {
      _showCompletionDialog(e.message);
    } on AtException catch (e) {
      _showCompletionDialog(e.message);
    }

    if (res != null && res.isError == false) {
      _showCompletionDialog('OTP saved successfully');
    }
  }

  _showCompletionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
