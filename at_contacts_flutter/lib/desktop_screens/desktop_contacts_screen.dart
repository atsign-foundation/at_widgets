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
  Key? key;
  DesktopContactsScreen(
    this.onBackArrowTap, {
    this.key,
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
      List<AtContact> _result, _result2;
      if (widget.isBlockedScreen) {
        _result2 = await _contactService!.fetchBlockContactList();
        if (_result2.isEmpty) {
          if (mounted) {
            setState(() {
              errorOcurred = true;
            });
          }
        }
      } else {
        _result = await _contactService!.fetchContacts();
        if (_result.isEmpty) {
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
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    widget.onBackArrowTap();
                  },
                  child: const Icon(Icons.arrow_back,
                      size: 25, color: Colors.black),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  widget.isBlockedScreen ? 'Blocked Contacts' : 'All Contacts',
                  style: CustomTextStyles.desktopPrimaryRegular24,
                ),
                const SizedBox(
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
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: ColorConstants.greyText,
                        ),
                        filled: true,
                        fillColor: ColorConstants.scaffoldColor,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.search,
                            color: ColorConstants.greyText,
                            size: 35,
                          ),
                        ),
                      ),
                      style: const TextStyle(
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
                    ? const SizedBox()
                    : CommonButton(
                        'Add Contact',
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => const AddContactDialog(),
                          );
                        },
                        leading: const Icon(Icons.add,
                            size: 25, color: Colors.white),
                        color: ColorConstants.orangeColor,
                        border: 3,
                        height: 45,
                        width: 170,
                        fontSize: 18,
                        removePadding: true,
                      )
              ],
            ),
            const SizedBox(
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
                          return const SizedBox();
                        } else if (snapshot.connectionState ==
                                ConnectionState.active &&
                            !snapshot.hasError) {
                          var itemCount = snapshot.data!.length;
                          return ListView.separated(
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              var baseContact = snapshot.data![index]!;

                              if (baseContact.contact!.atSign!
                                  .contains(searchText)) {
                                _filteredList.add(baseContact);
                                return contactsTile(baseContact);
                              } else {
                                _filteredList.remove(baseContact);

                                if (_filteredList.isEmpty &&
                                    searchText.trim().isNotEmpty &&
                                    index == itemCount - 1) {
                                  return const Center(
                                    child: Text('No Contacts found'),
                                  );
                                }

                                return const SizedBox();
                              }
                            },
                            separatorBuilder: (context, index) {
                              var baseContact = snapshot.data![index]!;
                              if (baseContact.contact!.atSign!
                                  .contains(searchText)) {
                                return const Divider(
                                  thickness: 0.2,
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        } else {
                          return const SizedBox();
                        }
                      })
                  : StreamBuilder<List<BaseContact?>>(
                      stream: _contactService!.contactStream,
                      initialData: _contactService!.baseContactList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (snapshot.connectionState ==
                                ConnectionState.active &&
                            !snapshot.hasError) {
                          var itemCount = snapshot.data!.length;
                          return ListView.separated(
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              var contact = snapshot.data![index]!;

                              if (contact.contact!.atSign!
                                  .contains(searchText)) {
                                _filteredList.add(contact);
                                return contactsTile(contact);
                              } else {
                                _filteredList.remove(contact);

                                if (_filteredList.isEmpty &&
                                    searchText.trim().isNotEmpty &&
                                    index == itemCount - 1) {
                                  return const Center(
                                    child: Text('No Contacts found'),
                                  );
                                }

                                return const SizedBox();
                              }
                            },
                            separatorBuilder: (context, index) {
                              var contact = snapshot.data![index]!;
                              if (contact.contact!.atSign!
                                  .contains(searchText)) {
                                return const Divider(
                                  thickness: 0.2,
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactsTile(BaseContact contact) {
    String? name;
    Uint8List? image;
    if (contact.contact!.tags != null) {
      if (contact.contact!.tags!['name'] != null) {
        name = contact.contact!.tags!['name'];
      }
      if (contact.contact!.tags!['image'] != null) {
        List<int> intList = contact.contact!.tags!['image'].cast<int>();
        image = Uint8List.fromList(intList);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          image != null
              ? CustomCircleAvatar(
                  key: Key(contact.contact!.atSign ?? ''),
                  byteImage: image,
                  nonAsset: true,
                  size: 50,
                )
              : ContactInitial(
                  initials: contact.contact!.atSign ?? '',
                  maxSize: 50,
                  minSize: 50,
                ),
          const SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 250,
            child: Text(
              name ?? contact.contact!.atSign ?? '',
              style: CustomTextStyles.primaryNormal20,
            ),
          ),
          const SizedBox(
            width: 70,
          ),
          Text(contact.contact!.atSign ?? '',
              style: CustomTextStyles.desktopSecondaryRegular18),
          const Spacer(),
          ContactListTile(
            contact,
            isBlockedScreen: widget.isBlockedScreen,
            // key: UniqueKey(),
          ),
          const SizedBox(
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
  Key? key;
  ContactListTile(
    this.baseContact, {
    this.key,
    this.isBlockedScreen = false,
  }) : super(key: key);

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
            _contactService!.updateState(STATE_UPDATE.markFav, contact, true);
            await _contactService?.markFavContact(contact);
            _contactService!.updateState(STATE_UPDATE.markFav, contact, false);
          },
          child: widget.baseContact!.isMarkingFav!
              ? const SizedBox(
                  width: 25, height: 25, child: CircularProgressIndicator())
              : Container(
                  child: contact.favourite!
                      ? const Icon(
                          Icons.star,
                          color: ColorConstants.orangeColor,
                        )
                      : const Icon(Icons.star_border),
                ),
        ),
        const SizedBox(
          width: 50,
        ),
        widget.baseContact!.isBlocking!
            ? const SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  _contactService!
                      .updateState(STATE_UPDATE.block, contact, true);
                  await _contactService!
                      .blockUnblockContact(contact: contact, blockAction: true);
                  _contactService!
                      .updateState(STATE_UPDATE.block, contact, false);
                },
                child: const Icon(
                  Icons.block,
                  color: ColorConstants.orangeColor,
                ),
              ),
        const SizedBox(
          width: 50,
        ),
        widget.baseContact!.isDeleting!
            ? const SizedBox(
                width: 25, height: 25, child: CircularProgressIndicator())
            : InkWell(
                onTap: () async {
                  _contactService!
                      .updateState(STATE_UPDATE.delete, contact, true);
                  await _contactService!
                      .deleteAtSign(atSign: contact.atSign ?? '');
                  _contactService!
                      .updateState(STATE_UPDATE.delete, contact, false);
                },
                child: const Icon(
                  Icons.delete,
                ),
              ),
        const SizedBox(
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
        ? const SizedBox(
            width: 25, height: 25, child: CircularProgressIndicator())
        : InkWell(
            onTap: () async {
              _contactService!.updateState(STATE_UPDATE.unblock, contact, true);
              await _contactService!
                  .blockUnblockContact(contact: contact, blockAction: false);
              _contactService!
                  .updateState(STATE_UPDATE.unblock, contact, false);
            },
            child: Text(
              'Unblock',
              style: CustomTextStyles.blueNormal20,
            ),
          );
  }
}
