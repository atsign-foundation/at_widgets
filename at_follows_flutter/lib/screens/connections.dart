import 'package:at_client_mobile/at_client_mobile.dart';
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
  ///Perform operations like follow/following for a particular @sign.
  final AtClientService atClientserviceInstance;

  ///color to match with your app theme. Defaults to [orange].
  final Color? appColor;

  ///name of the follower atsign received from notification to follow them back immediately.
  final String? followerAtsignTitle;

  ///atsign to follow from webapp.
  final String? followAtsignTitle;
  // final bool isLightTheme;
  Connections(
      {required this.atClientserviceInstance,
      this.appColor,
      this.followAtsignTitle,
      this.followerAtsignTitle});
  @override
  _ConnectionsState createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  List<ConnectionTab> connectionTabs = <ConnectionTab>[];
  int? lastAccessedIndex;
  TextEditingController searchController = TextEditingController();
  final ConnectionProvider _connectionProvider = ConnectionProvider();
  final ConnectionsService _connectionService = ConnectionsService();
  // String followAtsignTitle;
  // String followerAtsignTitle;

  @override
  void initState() {
    String currentAtsign =
        (widget.atClientserviceInstance.atClient!.currentAtSign) ?? '';
    _connectionService.init(currentAtsign);
    _connectionProvider.init(currentAtsign);
    ColorConstants.darkTheme = false;
    ColorConstants.appColor = widget.appColor;
    SDKService().setClientService = widget.atClientserviceInstance;
    Strings.directoryUrl = Strings.rootdomain == 'root.atsign.org'
        ? 'https://atsign.directory/'
        : 'https://directory.atsign.wtf/';
    _connectionService.startMonitor().then((bool value) => setState(() {
          _formConnectionTabs(2);
        }));

    _connectionService.followerAtsign = widget.followerAtsignTitle;
    _connectionService.followAtsign = widget.followAtsignTitle;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConstants.backgroundColor,
        appBar: CustomAppBar(
          title: SDKService().atsign,
          showTitle: true,
          showBackButton: true,
          showQr:
              connectionTabs.isNotEmpty ? connectionTabs[1].isActive : false,
        ),
        body: ChangeNotifierProvider<ConnectionProvider>.value(
          builder: (BuildContext context, Widget? child) {
            if (_connectionService.isMonitorStarted) {
              return child!;
            } else {
              return SizedBox(
                height: SizeConfig().screenHeight * 0.6,
                width: SizeConfig().screenWidth,
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color?>(
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
                          valueColor: AlwaysStoppedAnimation<Color?>(
                              ColorConstants.buttonHighLightColor)),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          for (int index = 0;
                              index < connectionTabs.length;
                              index++)
                            CustomButton(
                              showCount: true,
                              count:
                                  _getFollowsCount(connectionTabs[index].count),
                              width: 150.0.toWidth,
                              isActive: connectionTabs[index].isActive,
                              text: connectionTabs[index].name,
                              onPressedCallBack: (bool isActive) {
                                if (index != lastAccessedIndex &&
                                    lastAccessedIndex != null &&
                                    !connectionTabs[index].isActive) {
                                  if (_connectionProvider.status == null) {
                                    _connectionProvider
                                        .setStatus(Status.getData);
                                  }
                                  connectionTabs[lastAccessedIndex!].isActive =
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
                        style: CustomTextStyles.fontR16primary,
                        onChanged: (String? value) {
                          if (value == null || value.isEmpty) {
                            FocusScope.of(context).unfocus();
                          } else {
                            setState(() {});
                          }
                        },
                        textInputAction: TextInputAction.search,
                        controller: searchController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(18.toFont),
                            filled: true,
                            fillColor: ColorConstants.fillColor,
                            hintText: Strings.search,
                            hintStyle: CustomTextStyles.fontR16primary,
                            prefixIcon: Icon(Icons.filter_list,
                                size: 20.toFont, color: ColorConstants.primary),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor!)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0.toFont),
                                borderSide: BorderSide(
                                    color: ColorConstants.borderColor!))),
                      ),
                      SizedBox(height: 20.toHeight),
                      if (connectionTabs.isNotEmpty &&
                          connectionTabs[0].isActive)
                        Followers(
                          count: () {
                            _getCount();
                          },
                          searchText: searchController.text,
                        ),
                      if (connectionTabs.isNotEmpty &&
                          connectionTabs[1].isActive)
                        Followers(
                          isFollowing: true,
                          searchText: searchController.text,
                          count: () {
                            _getCount();
                          },
                        )
                    ],
                  ),
          ),
        ));
  }

  void _getCount() {
    bool isCalled = false;
    if (connectionTabs[0].count != ConnectionProvider().followersList!.length) {
      connectionTabs[0].count = ConnectionProvider().followersList!.length;
      setState(() {});
      isCalled = true;
    }
    if (connectionTabs[1].count != ConnectionProvider().followingList!.length) {
      connectionTabs[1].count = ConnectionProvider().followingList!.length;
      if (!isCalled) setState(() {});
    }
  }

  String _getFollowsCount(int? count) {
    count ??= 0;
    String countValue;
    if (count / 100000 > 1) {
      countValue = count % 100000 == 0
          ? (count / 100000).toStringAsFixed(0)
          : (count / 100000).toStringAsFixed(1);
      countValue += 'M';
    } else if (count / 1000 > 1) {
      countValue = count % 1000 == 0
          ? (count / 1000).toStringAsFixed(0)
          : (count / 1000).toStringAsFixed(1);
      countValue += 'K';
    } else {
      countValue = count.toString();
    }
    return countValue;
  }

  void _formConnectionTabs(int tabsCount) {
    bool isFollowingOption =
        widget.followAtsignTitle != null || widget.followerAtsignTitle != null;
    lastAccessedIndex = isFollowingOption ? 1 : 0;
    connectionTabs.addAll(<ConnectionTab>[
      ConnectionTab(name: Strings.followers, isActive: !isFollowingOption),
      ConnectionTab(name: Strings.following, isActive: isFollowingOption),
    ]);
  }
}

class ConnectionTab {
  bool isActive;
  String name;
  int? count;
  ConnectionTab({this.isActive = false, required this.name});
}
