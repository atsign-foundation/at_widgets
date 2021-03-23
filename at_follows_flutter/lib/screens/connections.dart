import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';
import 'package:at_follows_flutter/services/size_config.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:at_follows_flutter/widgets/custom_appbar.dart';
import 'package:at_follows_flutter/widgets/custom_button.dart';
import 'package:at_follows_flutter/widgets/followers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Displays list of connections that are following and being followed by the given [atsign].
///[atClientserviceInstance] is the atclient service instance through which different operations of [at_client] sdk will be used.
///Throws assertion error if [service] is null.
///To enable darkTheme set [isDarkTheme] as true.
class Connections extends StatefulWidget {
  final atClientserviceInstance;
  final bool isDarkTheme;
  final Color appColor;

  ///name of the follower atsign received from notification to follow them back immediately.
  final String followerAtsignTitle;

  ///atsign to follow from webapp.
  final String followAtsignTitle;
  // final bool isLightTheme;
  Connections(
      {@required this.atClientserviceInstance,
      this.isDarkTheme = false,
      this.appColor,
      this.followAtsignTitle,
      this.followerAtsignTitle});
  @override
  _ConnectionsState createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  List<ConnectionTab> connectionTabs = [];
  int lastAccessedIndex;
  TextEditingController searchController = TextEditingController();
  ConnectionProvider _connectionProvider = ConnectionProvider();
  var _connectionService = ConnectionsService();

  @override
  void initState() {
    _connectionService.init();
    _connectionProvider.init();
    ColorConstants.darkTheme = widget.isDarkTheme;
    ColorConstants.appColor = widget.appColor;
    SDKService().setClientService = widget.atClientserviceInstance;
    _connectionService.followerAtsign = widget.followerAtsignTitle;
    _connectionService.followAtsign = widget.followAtsignTitle;
    _connectionService.startMonitor().then((value) => setState(() {
          _formConnectionTabs(2);
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        appBar: CustomAppBar(
          title: SDKService().atsign,
          showTitle: true,
          showBackButton: true,
          showQr:
              connectionTabs.isNotEmpty ? connectionTabs[1].isActive : false,
        ),
        body: ChangeNotifierProvider<ConnectionProvider>.value(
          builder: (context, child) {
            if (_connectionService.isMonitorStarted)
              return child;
            else {
              return SizedBox(
                height: SizeConfig().screenHeight * 0.6,
                width: SizeConfig().screenWidth,
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.buttonHighLightColor)),
                ),
              );
            }
          },
          value: _connectionProvider,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16.toWidth, vertical: 12.toHeight),
            child: !_connectionService.isMonitorStarted
                ? SizedBox(
                    height: SizeConfig().screenHeight * 0.6,
                    width: SizeConfig().screenWidth,
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConstants.buttonHighLightColor)),
                    ),
                  )
                : Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int index = 0;
                              index < connectionTabs.length;
                              index++)
                            CustomButton(
                              width: 150.0.toWidth,
                              isActive: connectionTabs[index].isActive,
                              text: connectionTabs[index].name,
                              onPressedCallBack: (isActive) {
                                if (index != lastAccessedIndex &&
                                    lastAccessedIndex != null &&
                                    !connectionTabs[index].isActive) {
                                  _connectionProvider.setStatus(Status.getData);
                                  connectionTabs[lastAccessedIndex].isActive =
                                      false;
                                  connectionTabs[index].isActive = isActive;
                                  lastAccessedIndex = index;
                                  setState(() {});
                                }
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 20.toHeight),
                      TextField(
                        onChanged: (value) {
                          setState(() {});
                        },
                        textInputAction: TextInputAction.search,
                        controller: searchController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: ColorConstants.fillColor,
                            labelText: Strings.Search.toUpperCase(),
                            labelStyle: CustomTextStyles.fontR16primary,
                            prefixIcon: Icon(Icons.search,
                                color: ColorConstants.primary),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor))),
                      ),
                      SizedBox(height: 20.toHeight),
                      if (connectionTabs[0].isActive)
                        Followers(
                          searchText: searchController.text,
                        ),
                      if (connectionTabs[1].isActive)
                        Followers(
                          isFollowing: true,
                          searchText: searchController.text,
                        )
                    ],
                  ),
          ),
        ));
  }

  _formConnectionTabs(int tabsCount) {
    var isFollowingOption =
        widget.followAtsignTitle != null || widget.followerAtsignTitle != null;
    lastAccessedIndex = isFollowingOption ? 1 : 0;
    connectionTabs.addAll([
      ConnectionTab(name: Strings.Followers, isActive: !isFollowingOption),
      ConnectionTab(name: Strings.Following, isActive: isFollowingOption),
    ]);
  }
}

class ConnectionTab {
  bool isActive;
  String name;
  ConnectionTab({this.isActive = false, @required this.name});
}
