import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/screens/new_version/widget/avatar_widget.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SingleContactWidget extends StatefulWidget {
  final List<AtContact> contacts;
  final bool showGroups;
  final bool showContacts;
  final String textSearch;
  final Function(AtContact contact)? onTapContact;

  const SingleContactWidget({
    Key? key,
    required this.contacts,
    this.showGroups = false,
    this.showContacts = true,
    this.textSearch = '',
    this.onTapContact,
  }) : super(key: key);

  @override
  State<SingleContactWidget> createState() => _SingleContactWidgetState();
}

class _SingleContactWidgetState extends State<SingleContactWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: 27,
      shrinkWrap: true,
      itemBuilder: (context, alphabetIndex) {
        List<AtContact> contactsForAlphabet = [];
        var currentChar = String.fromCharCode(alphabetIndex + 65).toUpperCase();

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
            Padding(
              padding: const EdgeInsets.only(left: 9, right: 8, bottom: 10),
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
            contactListBuilder(contactsForAlphabet)
          ],
        );
      },
    );
  }

  Widget contactListBuilder(
    List<AtContact> listContact,
  ) {
    return ListView.builder(
      itemCount: listContact.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 18, 12),
          child: InkWell(
            onTap: () {
              widget.onTapContact?.call(
                listContact[index],
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AllColors().GRAY),
                color: Colors.white.withOpacity(0.6),
              ),
              child: Row(
                children: <Widget>[
                  AvatarWidget(
                    borderRadius: 18,
                    size: 39,
                    contact: listContact[index],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            listContact[index].atSign ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            listContact[index].tags?['name'] ??
                                listContact[index].atSign!.substring(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    AppVectors.icTrustActivated,
                    package: 'at_contacts_group_flutter',
                  )
                ],
              ),
            ),
          ),
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
  List<AtContact> getContactsForAlphabets(
    List<AtContact> _filteredList,
    String currentChar,
    int alphabetIndex,
  ) {
    List<AtContact> contactsForAlphabet = [];

    /// contacts, groups that does not starts with alphabets
    if (alphabetIndex == 26) {
      for (var contact in _filteredList) {
        if (widget.showContacts &&
            !RegExp(r'^[a-z]+$').hasMatch(
              contact.atSign![1].toLowerCase(),
            )) {
          contactsForAlphabet.add(contact);
        }
      }
    } else {
      for (var contact in _filteredList) {
        if (widget.showContacts &&
            contact.atSign![1].toUpperCase() == currentChar) {
          contactsForAlphabet.add(contact);
        }
      }
    }

    return contactsForAlphabet;
  }
}
