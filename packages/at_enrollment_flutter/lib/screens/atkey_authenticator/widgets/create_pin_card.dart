import 'package:at_enrollment_flutter/screens/create_pin.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:flutter/material.dart';

class CreatePinCard extends StatefulWidget {
  const CreatePinCard({super.key});

  @override
  State<CreatePinCard> createState() => _CreatePinCardState();
}

class _CreatePinCardState extends State<CreatePinCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: createPinBottomsheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  Images.createPin,
                  height: 36,
                  width: 112,
                  package: 'at_enrollment_flutter',
                ),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  child: Image.asset(
                    Images.forward,
                    width: 8,
                    height: 16,
                    package: 'at_enrollment_flutter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a PIN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You can create a PIN to speed up your onboarding experience across apps.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  createPinBottomsheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const CreatePin();
      },
    );
  }
}
