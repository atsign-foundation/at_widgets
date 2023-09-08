import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/action_button_widget.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/enter_atsign_widget.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/enter_pin_widget.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/home_title_widget.dart';
import 'package:at_enrollment_flutter/screens/welcome/welcome.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String atSignValue = "";
  String pinValue = "";
  bool tooltipEnabled = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.bgColor,
        leading: InkWell(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Column(
            children: [
              const SizedBox(height: 224),
              const HomeTitleWidget(),
              EnterAtSignWidget(
                onChange: (String val) {
                  setState(() {
                    if (tooltipEnabled) tooltipEnabled = !tooltipEnabled;
                    atSignValue = val;
                  });
                  var enrollmentConfig = EnrollmentConfig(currentAtsign: val);
                  EnrollmentServiceWrapper.getInstance().updateEnrollmentConfig(
                    enrollmentConfig,
                  );
                },
                isTooltipEnabled: tooltipEnabled,
                isAtSignEmpty: atSignValue.isEmpty,
                onShowTooltip: () {
                  setState(() {
                    tooltipEnabled = !tooltipEnabled;
                  });
                },
              ),
              if (atSignValue.isNotEmpty) ...[
                const SizedBox(height: 16),
                EnterPinWidget(
                  onChange: (String val) {
                    pinValue = val;
                    print('pin : $pinValue');

                    var enrollmentConfig = EnrollmentConfig(pin: val);
                    EnrollmentServiceWrapper.getInstance()
                        .updateEnrollmentConfig(
                      enrollmentConfig,
                    );
                  },
                  onSubmit: () async {
                    var enrollmentService =
                        EnrollmentServiceWrapper.getInstance();
                    if (enrollmentService.enrollmentConfig.currentAtsign !=
                        null) {
                      EnrollmentServiceWrapper.getInstance().init();
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Welcome(
                            atSign: atSignValue,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
              if (tooltipEnabled) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFFFEFEC),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: const Text(
                    "An atSign will generate an atKey which gives you access to all our apps. Your atSign name should represent you as it is what you share with the community! ",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              ],
              const SizedBox(height: 16),
              ActionButtonWidget(isAtSignEmpty: atSignValue.isEmpty),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
