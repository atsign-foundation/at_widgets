import 'package:at_onboarding_flutter_example/utils/app_constants.dart';
import 'package:at_onboarding_flutter_example/dashboard.dart';
import 'package:at_onboarding_flutter_example/services/at_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

import 'package:flutter/material.dart';

import 'contact_initial.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String> atSignList;
  final Function? showLoader;
  const AtSignBottomSheet(
      {Key key = const Key('atsign'),
      this.atSignList = const [],
      this.showLoader})
      : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  AtService atService = AtService.getInstance();
  bool isLoading = false;
  AtClientPreference? atClientPreferenceLocal;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    atService
        .getAtClientPreference()
        .then((value) => atClientPreferenceLocal = value);
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            builder: (context) => ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                height: 100,
                width: screenSize.width,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.atSignList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: isLoading
                            ? () {}
                            : () async {
                                if (mounted) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                }
                                Onboarding(
                                  context: context,
                                  atsign: widget.atSignList[index],
                                  // This domain parameter is optional.
                                  domain: AppConstants.rootDomain,
                                  atClientPreference: atClientPreferenceLocal!,
                                  appColor:
                                      const Color.fromARGB(255, 240, 94, 62),
                                  onboard: (Map<String?, AtClientService> value,
                                      String? atsign) {
                                    AtService.getInstance().atClientServiceMap =
                                        value;
                                    if (atsign != null) {
                                      AtService.getInstance()
                                          .makeAtsignPrimary(atsign);
                                    }
                                    print('Successfully onboarded $atsign');
                                  },
                                  onError: (Object? error) {
                                    print('Onboarding throws $error error');
                                  },
                                  rootEnvironment: RootEnvironment.staging,
                                  // API Key is mandatory for production environment.
                                  // appAPIKey: YOUR_API_KEY_HERE
                                  nextScreen: const DashBoard(),
                                );

                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: Column(
                            children: [
                              ContactInitial(
                                initials: widget.atSignList[index],
                              ),
                              Text(widget.atSignList[index])
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        Onboarding(
                          context: context,
                          atsign: '',
                          // This domain parameter is optional.
                          domain: AppConstants.rootDomain,
                          atClientPreference: atClientPreferenceLocal!,
                          appColor: const Color.fromARGB(255, 240, 94, 62),
                          onboard: (Map<String?, AtClientService> value,
                              String? atsign) {
                            AtService.getInstance().atClientServiceMap = value;
                            if (atsign != null) {
                              AtService.getInstance().makeAtsignPrimary(atsign);
                            }
                            print('Successfully onboarded $atsign');
                          },
                          onError: (Object? error) {
                            print('Onboarding throws $error error');
                          },
                          rootEnvironment: RootEnvironment.staging,
                          // API Key is mandatory for production environment.
                          // appAPIKey: YOUR_API_KEY_HERE
                          nextScreen: const DashBoard(),
                        );

                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        height: 40,
                        width: 40,
                        child: const Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.orange,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
                child: Column(
                  children: const [
                    Text(
                      'Switching atsign...',
                      style: TextStyle(
                        color: Color(0xffF05E3F),
                        fontSize: 16,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFF05E3E))),
                  ],
                ),
              )
            : const SizedBox(
                height: 100,
              ),
      ],
    );
  }
}
