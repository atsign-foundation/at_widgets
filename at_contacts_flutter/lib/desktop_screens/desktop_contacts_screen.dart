import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
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
  var _filteredList = <AtContact>[];

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
                  ? StreamBuilder<List<AtContact?>>(
                      stream: _contactService!.blockedContactStream,
                      initialData: _contactService!.blockContactList,
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
                              // var contact = snapshot.data![index]!;
                              // return contacts_tile(contact);
                              var contact = snapshot.data![index]!;

                              if (contact.atSign.contains(searchText)) {
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
                              if (contact.atSign.contains(searchText)) {
                                return Divider(
                                  thickness: 0.2,
                                );
                              }
                              return SizedBox();
                            },
                          );
                        } else
                          return SizedBox();
                      })
                  : StreamBuilder<List<AtContact?>>(
                      stream: _contactService!.contactStream,
                      initialData: _contactService!.contactList,
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

                              if (contact.atSign.contains(searchText)) {
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
                              if (contact.atSign.contains(searchText)) {
                                return Divider(
                                  thickness: 0.2,
                                );
                              }
                              return SizedBox();
                            },
                          );
                        } else
                          return SizedBox();
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget contacts_tile(AtContact contact) {
    String? name;
    var image;
    if (contact.tags != null) {
      if (contact.tags['name'] != null) {
        name = contact.tags['name'];
      }
      if (contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
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
                  size: 30,
                )
              : ContactInitial(
                  initials: contact.atSign,
                  maxSize: 50,
                  minSize: 50,
                ),
          SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 250,
            child: Text(
              name ?? contact.atSign,
              style: CustomTextStyles.primaryNormal20,
            ),
          ),
          SizedBox(
            width: 70,
          ),
          Text(contact.atSign,
              style: CustomTextStyles.desktopSecondaryRegular18),
          Spacer(),
          ContactListTile(contact, isBlockedScreen: widget.isBlockedScreen),
          SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }
}

class ContactListTile extends StatefulWidget {
  AtContact? contact;
  bool isBlockedScreen;
  ContactListTile(this.contact, {this.isBlockedScreen = false});

  @override
  _ContactListTileState createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  bool isBlockingContact = false,
      isUnblockingContact = false,
      isDeletingContact = false;
  ContactService? _contactService;
  late AtContact contact;
  @override
  void initState() {
    contact = widget.contact!;
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
        isBlockingContact
            ? SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  setState(() {
                    isBlockingContact = true;
                  });
                  await _contactService!
                      .blockUnblockContact(contact: contact, blockAction: true);
                  setState(() {
                    isBlockingContact = false;
                  });
                },
                child: Icon(
                  Icons.block,
                  color: ColorConstants.orangeColor,
                ),
              ),
        SizedBox(
          width: 50,
        ),
        isDeletingContact
            ? SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  setState(() {
                    isDeletingContact = true;
                  });
                  await _contactService!.deleteAtSign(atSign: contact.atSign);
                  setState(() {
                    isDeletingContact = false;
                  });
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
    return isUnblockingContact
        ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator())
        : InkWell(
            onTap: () async {
              setState(() {
                isUnblockingContact = true;
              });

              await _contactService!
                  .blockUnblockContact(contact: contact, blockAction: false);

              setState(() {
                isUnblockingContact = false;
              });
            },
            child: Text(
              'Unblock',
              style: CustomTextStyles.blueNormal20,
            ),
          );
  }
}
