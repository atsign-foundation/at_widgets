import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class CreatePin extends StatefulWidget {
  const CreatePin({super.key});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 10),
            const Text(
              'PIN is used to prevent authentication spam',
              style: TextStyle(fontSize: 13, color: ColorConstant.lightGrey),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 58,
                  width: 51,
                  color: ColorConstant.lightGrey.withOpacity(0.2),
                  padding: const EdgeInsets.only(left: 20),
                  child: const TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 58,
                  width: 51,
                  color: ColorConstant.lightGrey.withOpacity(0.2),
                  padding: const EdgeInsets.only(left: 20),
                  child: const TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 58,
                  width: 51,
                  color: ColorConstant.lightGrey.withOpacity(0.2),
                  padding: const EdgeInsets.only(left: 20),
                  child: const TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 58,
                  width: 51,
                  color: ColorConstant.lightGrey.withOpacity(0.2),
                  padding: const EdgeInsets.only(left: 20),
                  child: const TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            CustomButton(
              width: double.infinity,
              buttonText: 'Save',
              fontColor: Colors.white,
              buttonColor: ColorConstant.orange,
              onPressed: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
