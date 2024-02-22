import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestCard extends StatefulWidget {
  const EnrollmentRequestCard({super.key});

  @override
  State<EnrollmentRequestCard> createState() => _EnrollmentRequestCardState();
}

class _EnrollmentRequestCardState extends State<EnrollmentRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 334,
      height: 160,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Max’s Iphone 15 Pro Max', style: TextStyle(fontSize: 13)),
          Text(
            'SSH No Ports',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text('Read Only', style: TextStyle(fontSize: 13)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                width: 130,
                buttonText: 'Deny',
                fontColor: Colors.grey,
                buttonColor: Colors.grey.withOpacity(0.2),
                onPressed: () {
                  setState(() {});
                },
              ),
              CustomButton(
                width: 130,
                buttonText: 'Approve',
                fontColor: Colors.white,
                buttonColor: ColorConstant.orange,
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
