import 'dart:async';
import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/screens/welcome/welcome.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class GeneratingYourAtKey extends StatefulWidget {
  const GeneratingYourAtKey({super.key});

  @override
  State<GeneratingYourAtKey> createState() => _GeneratingYourAtKeyState();
}

class _GeneratingYourAtKeyState extends State<GeneratingYourAtKey> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Welcome(atSign: ''),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      body: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 32,
                      width: 32,
                      alignment: Alignment.center,
                      child: Image.asset(
                        Images.back,
                        height: 28,
                        width: 12,
                        package: 'at_enrollment_flutter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'What\'s going on?',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Generating your atkey',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    Images.loading,
                    width: 336,
                    height: 304,
                    fit: BoxFit.cover,
                    package: 'at_enrollment_flutter',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: ColorConstant.lightOrange,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Important',
                    style: TextStyle(
                      color: ColorConstant.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 52),
                  child: Text(
                    'Keep a copy of your atKeys! If you lose them and get signed out of all your apps, you might lose access to your data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstant.lightGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Button(
                    buttonText: 'Backup your atsign',
                    buttonColor: ColorConstant.orange,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    borderRadius: 41,
                    width: double.infinity,
                    prefix: Container(
                      width: 24,
                      height: 28,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 20),
                      child: Image.asset(
                        Images.backup,
                        width: 16,
                        height: 24,
                        package: 'at_enrollment_flutter',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
