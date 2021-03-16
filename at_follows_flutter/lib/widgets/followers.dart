import 'package:at_follows_flutter/domain/atsign.dart';
import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/exceptions/at_exception_handler.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:at_follows_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

class Followers extends StatefulWidget {
  final String searchText;
  final bool isFollowing;
  Followers({this.searchText, this.isFollowing = false});
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  List<Atsign> atsignsList = [];
  ConnectionsService _connectionsService = ConnectionsService();

  @override
  void initState() {
    super.initState();
    if (_connectionsService.followerAtsign != null) {
      _followAtsign(context);
    } else if (_connectionsService.followAtsign != null) {
      _followAtsign(context, isFollow: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(builder: (context, provider, _) {
      print('provider status is ${provider.status}......');
      if (provider.status == Status.loading) {
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(),
          ),
        );
      } else if (provider.status == Status.done) {
        atsignsList =
            // provider.atsignsList;
            widget.isFollowing
                ? provider.followingList
                : provider.followersList;
        if (atsignsList.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  widget.isFollowing
                      ? Strings.noFollowing
                      : Strings.noFollowers,
                  style: CustomTextStyles.fontR14primary),
            ],
          );
        }
        var tempAtsignList = [...atsignsList];
        if (widget.searchText.isNotEmpty) {
          tempAtsignList.retainWhere((atsign) {
            return atsign.title
                .toUpperCase()
                .contains(widget.searchText.toUpperCase());
          });
        }
        return Column(
          children: [
            SwitchListTile(
              title: Text(
                  widget.isFollowing
                      ? Strings.privateFollowingList
                      : Strings.privateFollowersList,
                  style: CustomTextStyles.fontBold14primary),
              value: widget.isFollowing
                  ? provider.connectionslistStatus.isFollowingPrivate
                  : provider.connectionslistStatus.isFollowersPrivate,
              onChanged: (value) {
                print('changed to $value');
                provider.changeListStatus(widget.isFollowing, value);
              },
              inactiveTrackColor: ColorConstants.inactiveTrackColor,
              inactiveThumbColor: ColorConstants.inactiveThumbColor,
              activeTrackColor: ColorConstants.activeTrackColor,
              activeColor: ColorConstants.activeColor,
            ),
            SizedBox(height: 10.toHeight),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 26,
              itemBuilder: (_, alphabetIndex) {
                List<Atsign> sortedListWithAlphabet = [];
                String currentAlphabet =
                    String.fromCharCode(alphabetIndex + 65).toUpperCase();

                tempAtsignList.forEach((atsign) {
                  var index = atsign.title.indexOf(RegExp('[A-Z]|[a-z]'));
                  if (atsign.title[index].toUpperCase() == currentAlphabet) {
                    if (widget.searchText != null &&
                        atsign.title
                            .toUpperCase()
                            .contains(widget.searchText.toUpperCase())) {
                      sortedListWithAlphabet.add(atsign);
                    }
                  }
                });
                if (sortedListWithAlphabet.isEmpty) {
                  return Container();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(currentAlphabet,
                            style: CustomTextStyles.fontR14primary),
                        Expanded(
                          child: Divider(
                            thickness: 0.8,
                            color: ColorConstants.borderColor,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 4.toHeight,
                    ),
                    ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          Atsign currentAtsign = sortedListWithAlphabet[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ColorConstants.fillColor,
                              radius: 20.toFont,
                              child: currentAtsign.profilePicture != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(20.toFont),
                                      child: Image.memory(
                                        currentAtsign.profilePicture,
                                      ),
                                    )
                                  : Icon(Icons.person),
                            ),
                            title: Text(currentAtsign.title,
                                style: CustomTextStyles.fontR16primary),
                            subtitle: currentAtsign.subtitle != null
                                ? Text(currentAtsign.subtitle,
                                    style: CustomTextStyles.fontR14primary)
                                : null,
                            trailing: CustomButton(
                                isActive: !currentAtsign.isFollowing,
                                onPressedCallBack: (value) async {
                                  print('received param is $value');
                                  if (value) {
                                    provider.unfollow(currentAtsign.title);
                                  } else {
                                    provider.follow(currentAtsign.title);
                                  }
                                  sortedListWithAlphabet[index].isFollowing =
                                      !value;
                                  setState(() {});
                                },
                                text: currentAtsign.isFollowing
                                    ? Strings.Unfollow
                                    : Strings.Follow),
                          );
                        },
                        separatorBuilder: (_, index) => Divider(
                              thickness: 0.8,
                              color: ColorConstants.borderColor,
                            ),
                        itemCount: sortedListWithAlphabet.length)
                  ],
                );
              },
            ),
          ],
        );
      } else if (provider.status == Status.error) {
        return AtExceptionHandler().handle(provider.error, context);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.getAtsignsList(isFollowing: widget.isFollowing);
        });
        print('Loading getAtsigns....');
        return SizedBox();
      }
    });
  }

  _followAtsign(BuildContext context, {bool isFollow = false}) {
    var atsign = isFollow
        ? ConnectionsService().followAtsign
        : ConnectionsService().followerAtsign;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  content: Text(
                      isFollow
                          ? '${Strings.followDescription}$atsign?'
                          : Strings.followBackDescription(atsign),
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.fontR14dark),
                  actions: [
                    CustomButton(
                      width: 100.toWidth,
                      isActive: false,
                      onPressedCallBack: (value) {
                        _connectionsService.followerAtsign = null;
                        Navigator.pop(context);
                      },
                      text: Strings.cancel,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.17),
                    CustomButton(
                      width: 100.toWidth,
                      isActive: true,
                      onPressedCallBack: (value) {
                        _connectionsService.followerAtsign = null;
                        Navigator.pop(context);
                        ConnectionProvider().follow(atsign);
                      },
                      text: isFollow ? Strings.Follow : Strings.followBack,
                    ),
                  ]));
    });
  }
}
