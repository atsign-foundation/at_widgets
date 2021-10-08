/// Screen exposed to see blocked contacts and unblock them

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/widgets/blocked_user_card.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class BlockedScreen extends StatefulWidget {
  @override
  _BlockedScreenState createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  late ContactService _contactService;
  bool errorOcurred = false;

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      var _result = await _contactService.fetchBlockContactList();
      if (_result == null) {
        if (mounted) {
          setState(() {
            errorOcurred = true;
          });
        }
      }
    });

    super.initState();
  }

  bool isBlocking = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      appBar: CustomAppBar(
        showBackButton: true,
        showTitle: true,
        showLeadingIcon: true,
        titleText: TextStrings().blockedContacts,
      ),
      body: errorOcurred
          ? ErrorScreen()
          : RefreshIndicator(
              color: Colors.transparent,
              strokeWidth: 0,
              backgroundColor: Colors.transparent,
              onRefresh: () async {
                await _contactService.fetchBlockContactList();
              },
              child: Container(
                color: ColorConstants.appBarColor,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        initialData: _contactService.baseBlockedList,
                        stream: _contactService.blockedContactStream,
                        builder: (context,
                            AsyncSnapshot<List<BaseContact?>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            return (snapshot.data!.isEmpty)
                                ? Center(
                                    child: Text(
                                      TextStrings().emptyBlockedList,
                                      style: TextStyle(
                                        fontSize: 16.toFont,
                                        color: ColorConstants.greyText,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 40.toHeight),
                                    itemCount:
                                        _contactService.blockContactList.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                      indent: 16.toWidth,
                                    ),
                                    itemBuilder: (context, index) {
                                      return BlockedUserCard(
                                        blockeduser:
                                            snapshot.data?[index]?.contact,
                                      );
                                    },
                                  );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
