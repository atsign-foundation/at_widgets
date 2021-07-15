import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/images.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:at_contacts_flutter/widgets/common_button.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class DesktopContactsScreen extends StatefulWidget {
  final bool isBlockedScreen;
  final Function onBackArrowTap;
  DesktopContactsScreen(
    Key key,
    this.onBackArrowTap, {
    this.isBlockedScreen = false,
  }) : super(key: key);

  @override
  _DesktopContactsScreenState createState() => _DesktopContactsScreenState();
}

class _DesktopContactsScreenState extends State<DesktopContactsScreen> {
  ContactService? _contactService;
  bool errorOcurred = false;
  String searchText = '';
  var _filteredList = <BaseContact>[];

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      var _result, _result2;
      if (widget.isBlockedScreen) {
        _result2 = await _contactService!.fetchBlockContactList();
        if (_result2 == null) {
          if (mounted) {
            setState(() {
              errorOcurred = true;
            });
          }
        }
      } else {
        _result = await _contactService!.fetchContacts();
        if (_result == null) {
          if (mounted) {
            setState(() {
              errorOcurred = true;
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.inputFieldColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    widget.onBackArrowTap();
                  },
                  child: Icon(Icons.arrow_back, size: 25, color: Colors.black),
                ),
                SizedBox(
                  width: 30,
                ),
                Text(
                  widget.isBlockedScreen ? 'Blocked Contacts' : 'All Contacts',
                  style: CustomTextStyles.desktopPrimaryRegular24,
                ),
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.isBlockedScreen
                            ? 'Search Blocked Contacts'
                            : 'Search Contact',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: ColorConstants.greyText,
                        ),
                        filled: true,
                        fillColor: ColorConstants.scaffoldColor,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.search,
                            color: ColorConstants.greyText,
                            size: 35,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorConstants.fontPrimary,
                      ),
                      onChanged: (s) {
                        setState(() {
                          searchText = s;
                          _filteredList = [];
                        });
                      }),
                ),
                SizedBox(
                  width: widget.isBlockedScreen ? 0 : 30,
                ),
                widget.isBlockedScreen
                    ? SizedBox()
                    : CommonButton(
                        'Add Contact',
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => AddContactDialog(),
                          );
                        },
                        leading: Icon(Icons.add, size: 25, color: Colors.white),
                        color: ColorConstants.orangeColor,
                        border: 3,
                        height: 45,
                        width: 170,
                        fontSize: 18,
                        removePadding: true,
                      )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: widget.isBlockedScreen
                  ? StreamBuilder<List<BaseContact?>>(
                      stream: _contactService!.blockedContactStream,
                      initialData: _contactService!.baseBlockedList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox();
                        } else if (snapshot.connectionState ==
                                ConnectionState.active &&
                            !snapshot.hasError) {
                          var itemCount = snapshot.data!.length;
                          return ListView.separated(
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              var baseContact = snapshot.data![index]!;

                              if (baseContact.contact!.atSign
                                  .contains(searchText)) {
                                _filteredList.add(baseContact);
                                return contacts_tile(baseContact);
                              } else {
                                _filteredList.remove(baseContact);

                                if (_filteredList.isEmpty &&
                                    searchText.trim().isNotEmpty &&
                                    index == itemCount - 1) {
                                  return Center(
                                    child: Text('No Contacts found'),
                                  );
                                }

                                return SizedBox();
                              }
                            },
                            separatorBuilder: (context, index) {
                              var baseContact = snapshot.data![index]!;
                              if (baseContact.contact!.atSign
                                  .contains(searchText)) {
                                return Divider(
                                  thickness: 0.2,
                                );
                              }
                              return SizedBox();
                            },
                          );
                        } else {
                          return SizedBox();
                        }
                      })
                  : StreamBuilder<List<BaseContact?>>(
                      stream: _contactService!.contactStream,
                      initialData: _contactService!.baseContactList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox();
                        } else if (snapshot.connectionState ==
                                ConnectionState.active &&
                            !snapshot.hasError) {
                          var itemCount = snapshot.data!.length;
                          return ListView.separated(
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              var contact = snapshot.data![index]!;

                              if (contact.contact!.atSign
                                  .contains(searchText)) {
                                _filteredList.add(contact);
                                return contacts_tile(contact);
                              } else {
                                _filteredList.remove(contact);

                                if (_filteredList.isEmpty &&
                                    searchText.trim().isNotEmpty &&
                                    index == itemCount - 1) {
                                  return Center(
                                    child: Text('No Contacts found'),
                                  );
                                }

                                return SizedBox();
                              }
                            },
                            separatorBuilder: (context, index) {
                              var contact = snapshot.data![index]!;
                              if (contact.contact!.atSign
                                  .contains(searchText)) {
                                return Divider(
                                  thickness: 0.2,
                                );
                              }
                              return SizedBox();
                            },
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget contacts_tile(BaseContact contact) {
    String? name;
    var image;
    if (contact.contact!.tags != null) {
      if (contact.contact!.tags['name'] != null) {
        name = contact.contact!.tags['name'];
      }
      if (contact.contact!.tags['image'] != null) {
        List<int> intList = contact.contact!.tags['image'].cast<int>();
        image = Uint8List.fromList(intList);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          image != null
              ? CustomCircleAvatar(
                  byteImage: image,
                  nonAsset: true,
                  size: 50,
                )
              : ContactInitial(
                  initials: contact.contact!.atSign,
                  size: 50,
                ),
          SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 250,
            child: Text(
              name ?? contact.contact!.atSign,
              style: CustomTextStyles.primaryNormal20,
            ),
          ),
          SizedBox(
            width: 70,
          ),
          Text(contact.contact!.atSign,
              style: CustomTextStyles.desktopSecondaryRegular18),
          Spacer(),
          ContactListTile(
            contact,
            isBlockedScreen: widget.isBlockedScreen,
            key: UniqueKey(),
          ),
          SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }
}

class ContactListTile extends StatefulWidget {
  BaseContact? baseContact;
  bool isBlockedScreen;
  UniqueKey? key;
  ContactListTile(
    this.baseContact, {
    this.key,
    this.isBlockedScreen = false,
  });

  @override
  _ContactListTileState createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  ContactService? _contactService;
  late AtContact contact;
  @override
  void initState() {
    contact = widget.baseContact!.contact!;
    _contactService = ContactService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isBlockedScreen ? _forBlockScreen() : _forContactsScreen();
  }

  Widget _forContactsScreen() {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            _contactService!.updateState(STATE_UPDATE.MARK_FAV, contact, true);
            await _contactService?.markFavContact(contact);
            _contactService!.updateState(STATE_UPDATE.MARK_FAV, contact, false);
          },
          child: widget.baseContact!.isMarkingFav!
              ? SizedBox(
                  width: 25, height: 25, child: CircularProgressIndicator())
              : Container(
                  child: contact.favourite!
                      ? Icon(
                          Icons.star,
                          color: ColorConstants.orangeColor,
                        )
                      : Icon(Icons.star_border),
                ),
        ),
        SizedBox(
          width: 50,
        ),
        widget.baseContact!.isBlocking!
            ? SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  _contactService!
                      .updateState(STATE_UPDATE.BLOCK, contact, true);
                  await _contactService!
                      .blockUnblockContact(contact: contact, blockAction: true);
                  _contactService!
                      .updateState(STATE_UPDATE.BLOCK, contact, false);
                },
                child: Icon(
                  Icons.block,
                  color: ColorConstants.orangeColor,
                ),
              ),
        SizedBox(
          width: 50,
        ),
        widget.baseContact!.isDeleting!
            ? SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  _contactService!
                      .updateState(STATE_UPDATE.DELETE, contact, true);
                  await _contactService!.deleteAtSign(atSign: contact.atSign);
                  _contactService!
                      .updateState(STATE_UPDATE.DELETE, contact, false);
                },
                child: Icon(
                  Icons.delete,
                ),
              ),
        SizedBox(
          width: 50,
        ),
        Image.asset(ImageConstants.sendIcon,
            width: 21.toWidth,
            height: 18.toHeight,
            package: 'at_contacts_flutter'),
      ],
    );
  }

  Widget _forBlockScreen() {
    return widget.baseContact!.isBlocking!
        ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator())
        : InkWell(
            onTap: () async {
              _contactService!.updateState(STATE_UPDATE.UNBLOCK, contact, true);
              await _contactService!
                  .blockUnblockContact(contact: contact, blockAction: false);
              _contactService!
                  .updateState(STATE_UPDATE.UNBLOCK, contact, false);
            },
            child: Text(
              'Unblock',
              style: CustomTextStyles.blueNormal20,
            ),
          );
  }
}
