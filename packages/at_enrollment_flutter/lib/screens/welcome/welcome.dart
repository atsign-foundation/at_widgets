import 'package:at_auth/at_auth.dart';
import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/common_widgets/input_otp_field.dart';
import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_enrollment_flutter/screens/enrollment_request/pending_enrollment_request.dart';
import 'package:at_enrollment_flutter/screens/welcome/widgets/type_selection_widget.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  final String atSign;

  const Welcome({
    super.key,
    required this.atSign,
  });

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  AccessType? selectedType;
  String otp = '';
  TextEditingController namespaceController = TextEditingController();
  String searchText = '';
  bool isLoading = false;
  EnrollmentServiceWrapper enrollmentApp =
      EnrollmentServiceWrapper.getInstance();

  @override
  void initState() {
    /// assigning default namespace to atClientPreference one
    addInitialNamespaceValue();
    enrollmentApp.getSentEnrollmentData();
    checkForEnrollmentData();
    super.initState();
  }

  /// If enrollment request is already present in keychain, another request can not be submitted
  checkForEnrollmentData() async {
    var enrollmentInfo = await enrollmentApp.getSentEnrollmentData();
    if (enrollmentInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PendingEnrollmentRequestScreens(
            enrollmentInfo: enrollmentInfo,
          ),
        ),
      );
    }
  }

  addInitialNamespaceValue() {
    var enrollmentService = EnrollmentServiceWrapper.getInstance();
    var atClientPreference = enrollmentService.getAtClientPreferences();
    namespaceController.text = atClientPreference.namespace ?? '';

    var enrollmentConfig = EnrollmentConfig(
      namespace: namespaceController.text,
    );
    EnrollmentServiceWrapper.getInstance().updateEnrollmentConfig(
      enrollmentConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: ColorConstant.bgColor,
        leading: InkWell(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 56),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Images.icon,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  package: 'at_enrollment_flutter',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.black,
                    fontSize: 30,
                  ),
                ),
                Text(
                  widget.atSign,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.orange,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Almost there... we just need to know a couple of things before',
                  style: TextStyle(
                    color: ColorConstant.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Enter the OTP found on your Primary Device ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: ColorConstant.lightGrey,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: ColorConstant.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Need Help Finding the OTP?',
                  style: TextStyle(
                    color: ColorConstant.lightGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: InputOTPField(
                    onChange: (value) {
                      var enrollmentConfig = EnrollmentConfig(otp: value);
                      EnrollmentServiceWrapper.getInstance()
                          .updateEnrollmentConfig(
                        enrollmentConfig,
                      );
                    },
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Would like to onboard into more Namespaces?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: ColorConstant.lightGrey,
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(right: 52),
              child: Text(
                'You can generate a key that allows access to more than one atApp on this device',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: ColorConstant.lightGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildSearchWidget(),
            if (searchText.isNotEmpty) buildSearchResultListWidget(),
            const SizedBox(height: 32),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'What Type of access do you need? ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: ColorConstant.lightGrey,
                          ),
                        ),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: ColorConstant.orange,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Important: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: ColorConstant.lightGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text:
                            'You will need to re-onboard if you change your mind later',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: ColorConstant.lightGrey,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    return TypeSelectionWidget(
                      isSelected: selectedType == AccessType.values[index],
                      accessType: AccessType.values[index],
                      onSelect: (AccessType value) {
                        Map<String, String> namespaceMap = {
                          namespaceController.text: ''
                        };

                        if (value == AccessType.readAndWrite) {
                          namespaceMap[namespaceController.text] = 'rw';
                        } else if (value == AccessType.readOnly) {
                          namespaceMap[namespaceController.text] = 'r';
                        }

                        var enrollmentConfig = EnrollmentConfig(
                          namespaceActionmap: namespaceMap,
                        );
                        EnrollmentServiceWrapper.getInstance()
                            .updateEnrollmentConfig(
                          enrollmentConfig,
                        );

                        setState(() {
                          selectedType = value;
                        });
                      },
                    );
                  },
                  itemCount: AccessType.values.length,
                ),
                const SizedBox(height: 80),
                isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            backgroundColor: ColorConstant.orange,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Button(
                          onPressed: sendEnrollmentRequest,
                          width: double.infinity,
                          buttonText: 'Continue',
                          buttonColor: ColorConstant.orange,
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  sendEnrollmentRequest() async {
    setState(() {
      isLoading = true;
    });
    AtEnrollmentResponse? res =
        await EnrollmentServiceWrapper.getInstance().sendEnrollmentRequest();
    if (res != null) {
      var sentEnrollmentRequest = await enrollmentApp.getSentEnrollmentData();
      if (sentEnrollmentRequest != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PendingEnrollmentRequestScreens(
              enrollmentInfo: sentEnrollmentRequest,
            ),
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget buildSearchWidget() {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 20, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: [
          Image.asset(
            Images.search,
            width: 20,
            height: 20,
            fit: BoxFit.cover,
            package: 'at_enrollment_flutter',
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: namespaceController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  var enrollmentConfig = EnrollmentConfig(namespace: value);
                  EnrollmentServiceWrapper.getInstance()
                      .updateEnrollmentConfig(enrollmentConfig);
                });
              },
              style: const TextStyle(
                color: ColorConstant.portlandOrange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: 'Search for namespace (app)',
                hintStyle: TextStyle(
                  color: ColorConstant.portlandOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (searchText.isNotEmpty) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                namespaceController.clear();
                setState(() {
                  searchText = '';
                });
              },
              child: Image.asset(
                Images.close,
                width: 16,
                height: 16,
                color: ColorConstant.lightGrey,
                fit: BoxFit.cover,
                package: 'at_enrollment_flutter',
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget buildSearchResultListWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return buildSearchResultItemWidget();
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16);
          },
          itemCount: 1,
        ),
      ],
    );
  }

  Widget buildSearchResultItemWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorConstant.searchColor,
      ),
      child: Row(
        children: [
          Image.asset(
            Images.appIcon,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            package: 'at_enrollment_flutter',
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'atBuzz',
              style: TextStyle(
                color: ColorConstant.searchTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            Images.close,
            width: 16,
            height: 16,
            fit: BoxFit.cover,
            package: 'at_enrollment_flutter',
          ),
        ],
      ),
    );
  }
}
