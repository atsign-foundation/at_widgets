import 'package:at_enrollment_app/screens/create_pin.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class CreatePinCard extends StatefulWidget {
  const CreatePinCard({super.key});

  @override
  State<CreatePinCard> createState() => _CreatePinCardState();
}

class _CreatePinCardState extends State<CreatePinCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: createPinBottomsheet,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ColorConstant.lightGrey.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '****',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create a PIN',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'You can create a PIN to speed up your onboarding experience across apps.',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  createPinBottomsheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: const BoxConstraints(
        minHeight: 450,
        maxHeight: double.maxFinite,
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CreatePin();
      },
    );
  }
}
