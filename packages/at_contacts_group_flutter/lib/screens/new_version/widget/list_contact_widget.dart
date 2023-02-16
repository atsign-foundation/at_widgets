import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart' hide ContactType;
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/widgets/contact_card_widget.dart';
import 'package:at_contacts_group_flutter/widgets/group_card_widget.dart';
import 'package:flutter/material.dart';

class ListContactWidget extends StatefulWidget {
  final List<GroupContactsModel?> contacts;
  final bool showGroups,
      showContacts,
      isHiddenAlpha,
      isMultiChoose,
      isChoiceMultiTypeContact;

  final String textSearch;
  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup group)? onTapGroup;
  final Function(List<AtContact> contacts)? chooseContacts;
  final Function(List<GroupContactsModel> contacts)? choiceMultiTypeContact;
  final List<GroupContactsModel>? selectedContacts;
  final List<AtContact>? contactsTrusted;
  final Function? onRefresh;
  final EdgeInsetsGeometry? padding;

  const ListContactWidget({
    Key? key,
    required this.contacts,
    this.showGroups = false,
    this.showContacts = true,
    this.textSearch = '',
    this.onTapContact,
    this.onRefresh,
    this.isHiddenAlpha = false,
    this.onTapGroup,
    this.chooseContacts,
    this.isMultiChoose = false,
    this.contactsTrusted,
    this.padding,
    this.isChoiceMultiTypeContact = false,
    this.choiceMultiTypeContact,
    this.selectedContacts,
  }) : super(key: key);

  @override
  State<ListContactWidget> createState() => _ListContactWidgetState();
}

class _ListContactWidgetState extends State<ListContactWidget> {
  List<AtContact> listContactSelected = [];
  List<GroupContactsModel> listContactChoice = [];

  @override
  void initState() {
    if ((widget.selectedContacts ?? []).isNotEmpty) {
      listContactChoice.addAll(widget.selectedContacts!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        physics: const ClampingScrollPhysics(),
        itemCount: 27,
        shrinkWrap: true,
        itemBuilder: (context, alphabetIndex) {
          List<GroupContactsModel?> contactsForAlphabet = [];
          var currentChar =
          String.fromCharCode(alphabetIndex + 65).toUpperCase();

          if (alphabetIndex == 26) {
            currentChar = 'Others';
          }

          contactsForAlphabet = getContactsForAlphabets(
            widget.contacts,
            currentChar,
            alphabetIndex,
          );

          if (contactsForAlphabet.isEmpty) {
            return const SizedBox();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isHiddenAlpha) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 8,
                    bottom: 10,
                    top: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        currentChar,
                        style: TextStyle(
                          fontSize: 20.toFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16.toWidth),
                      Expanded(
                        child: Divider(
                          color: AllColors().LIGHT_GRAY,
                          height: 1.toHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              contactListBuilder(contactsForAlphabet)
            ],
          );
        },
      ),
    );
  }

  Widget contactListBuilder(List<GroupContactsModel?> contactsForAlphabet,) {
    return ListView.builder(
      itemCount: contactsForAlphabet.length,
      padding: widget.padding ?? EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final contact = contactsForAlphabet[index]!.contact;
        return (contactsForAlphabet[index]!.contact != null)
            ? ContactCardWidget(
          contact: contact!,
          isTrusted: _checkTrustedContact(contact),
          isSelected: widget.isChoiceMultiTypeContact
              ? _isChoiceContact(
            contactsForAlphabet[index]!,
          )
              : _checkSelectedContact(contact),
          onTap: () {
            widget.isChoiceMultiTypeContact
                ? _onChoiceContacts(
              contactsForAlphabet[index]!,
            )
                : !widget.isMultiChoose
                ? widget.onTapContact?.call(contact)
                : _onChooseContact(contact);
          },
        )
            : GroupCardWidget(
          group: contactsForAlphabet[index]!.group!,
          isSelected: _isChoiceContact(
            contactsForAlphabet[index]!,
          ),
          onTap: () {
            widget.isChoiceMultiTypeContact
                ? _onChoiceContacts(
              contactsForAlphabet[index]!,
            )
                : widget.onTapGroup?.call(
              contactsForAlphabet[index]!.group!,
            );
          },
        );
      },
    );
  }

  // creates a list of contacts by merging atsigns and groups.
  List<GroupContactsModel?> getAllContactList(
      List<GroupContactsModel?> allGroupContactData) {
    var _filteredList = <GroupContactsModel?>[];
    for (var c in allGroupContactData) {
      if (widget.showContacts &&
          c!.contact != null &&
          c.contact!.atSign.toString().toUpperCase().contains(
            widget.textSearch.toUpperCase(),
          )) {
        _filteredList.add(c);
      }
      if (widget.showGroups &&
          c!.group != null &&
          c.group!.displayName != null &&
          c.group!.displayName!.toUpperCase().contains(
            widget.textSearch.toUpperCase(),
          )) {
        _filteredList.add(c);
      }
    }

    return _filteredList;
  }

  /// returns list of atsigns, that matches with [currentChar] in [_filteredList]
  List<GroupContactsModel?> getContactsForAlphabets(
      List<GroupContactsModel?> _filteredList,
      String currentChar,
      int alphabetIndex) {
    var contactsForAlphabet = <GroupContactsModel?>[];

    /// contacts, groups that does not starts with alphabets
    if (alphabetIndex == 26) {
      for (var c in _filteredList) {
        if (widget.showContacts &&
            c!.contact != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              c.contact!.atSign![1].toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (widget.showGroups &&
            c!.group != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              c.group!.displayName![0].toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
    } else {
      for (var c in _filteredList) {
        if (widget.showContacts &&
            c!.contact != null &&
            c.contact?.atSign![1].toUpperCase() == currentChar) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (widget.showGroups &&
            c!.group != null &&
            c.group?.displayName![0].toUpperCase() == currentChar) {
          contactsForAlphabet.add(c);
        }
      }
    }

    return contactsForAlphabet;
  }

  void _onChooseContact(AtContact contact) {
    if (listContactSelected.isEmpty) {
      listContactSelected.add(contact);
    } else {
      if (listContactSelected.contains(contact)) {
        listContactSelected.remove(contact);
      } else {
        listContactSelected.add(contact);
      }
    }
    widget.chooseContacts?.call(
      listContactSelected,
    );
    setState(() {});
  }

  void _onChoiceContacts(GroupContactsModel contact) {
    if (listContactChoice.isEmpty) {
      listContactChoice.add(contact);
    } else {
      bool isAdd = true;
      GroupContactsModel? contactExists;

      for (var element in listContactChoice) {
        contactExists = element;
        if (contact.contactType == ContactsType.CONTACT) {
          if (contact.contact?.atSign == element.contact?.atSign) {
            isAdd = false;
            break;
          }
        } else {
          if (contact.group?.groupId == element.group?.groupId) {
            isAdd = false;
            break;
          }
        }
      }

      if (!isAdd) {
        listContactChoice.remove(contactExists);
      } else {
        listContactChoice.add(contact);
      }
    }
    widget.choiceMultiTypeContact?.call(
      listContactChoice,
    );
    setState(() {});
  }

  bool _isChoiceContact(GroupContactsModel contact) {
    bool isSelected = false;
    for (var element in listContactChoice) {
      if (contact.contactType == ContactsType.CONTACT) {
        if (contact.contact?.atSign == element.contact?.atSign) {
          isSelected = true;
        }
      } else {
        if (contact.group?.groupId == element.group?.groupId) {
          isSelected = true;
        }
      }
    }

    return isSelected;
  }

  bool _checkSelectedContact(AtContact contact) {
    bool isSelected = false;
    for (var element in listContactSelected) {
      if (contact.atSign == element.atSign) {
        isSelected = true;
      }
    }

    return isSelected;
  }

  bool _checkTrustedContact(AtContact contact) {
    bool isTrusted = false;
    for (var element in (widget.contactsTrusted ?? [])) {
      if (contact.atSign == element.atSign) {
        isTrusted = true;
      }
    }

    return isTrusted;
  }
}
