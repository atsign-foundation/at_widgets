import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/screens/new_version/widget/list_contact_widget.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class ChoiceContactWidget extends StatefulWidget {
  final bool showGroups,
      showContacts,
      isHiddenAlpha,
      isMultiChoose,
      isChoiceMultiTypeContact;

  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup contact)? onTapGroup;
  final Function(List<AtContact> contact)? chooseContact;
  final Function(List<GroupContactsModel> contacts)? choiceMultiTypeContact;
  final List<AtContact>? contactsTrusted;
  final List<GroupContactsModel>? selectedContacts;

  const ChoiceContactWidget({
    Key? key,
    this.showGroups = false,
    this.showContacts = true,
    this.onTapContact,
    this.isHiddenAlpha = false,
    this.isMultiChoose = false,
    this.onTapGroup,
    this.chooseContact,
    this.contactsTrusted,
    this.choiceMultiTypeContact,
    this.isChoiceMultiTypeContact = false,
    this.selectedContacts,
  }) : super(key: key);

  @override
  State<ChoiceContactWidget> createState() => _ChoiceContactWidgetState();
}

class _ChoiceContactWidgetState extends State<ChoiceContactWidget> {
  late GroupService _groupService;
  late TextEditingController searchController;

  @override
  void initState() {
    _groupService = GroupService();
    searchController = TextEditingController();
    _groupService.fetchGroupsAndContacts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 44,
          margin: EdgeInsets.symmetric(
            horizontal: 32.toWidth,
            vertical: 18.toHeight,
          ),
          child: TextFormField(
            controller: searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF939393),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF939393),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.only(top: 12, left: 14),
              hintStyle: TextStyle(
                fontSize: 14.toFont,
                color: ColorConstants.greyText,
                fontWeight: FontWeight.normal,
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              hintText: 'Search by atSign or nickname',
            ),
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 14.toFont,
              color: ColorConstants.fontPrimary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        /*Padding(
          padding: const EdgeInsets.only(left: 31),
          child: Text(
            "Filter By",
            style: TextStyle(
              fontSize: 12.toFont,
              fontWeight: FontWeight.w500,
              color: AllColors().DARK_GRAY,
            ),
          ),
        ),*/
        Flexible(
          child: StreamBuilder<List<GroupContactsModel?>>(
            stream: _groupService.allContactsStream,
            initialData: _groupService.allContacts,
            builder: (context, snapshot) {
              if ((snapshot.connectionState == ConnectionState.waiting)) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // filtering contacts and groups
                var _filteredList = <GroupContactsModel?>[];
                _filteredList = getAllContactList(snapshot.data ?? []);

                if (_filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      TextStrings().noContactsFound,
                      style: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                }

                // renders contacts according to the initial alphabet
                return Scrollbar(
                  radius: const Radius.circular(11),
                  child: ListContactWidget(
                    contacts: _filteredList,
                    padding: const EdgeInsets.only(left: 24, right: 6),
                    showGroups: widget.showGroups,
                    showContacts: widget.showContacts,
                    onTapContact: widget.onTapContact,
                    onRefresh: () async {
                      await _groupService.fetchGroupsAndContacts();
                    },
                    isHiddenAlpha: widget.isHiddenAlpha,
                    isMultiChoose: widget.isMultiChoose,
                    onTapGroup: widget.onTapGroup,
                    chooseContacts: widget.chooseContact,
                    contactsTrusted: widget.contactsTrusted,
                    isChoiceMultiTypeContact: widget.isChoiceMultiTypeContact,
                    choiceMultiTypeContact: widget.choiceMultiTypeContact,
                    selectedContacts: widget.selectedContacts,
                  ),
                );
              }
            },
          ),
        ),
      ],
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
                searchController.text.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
      if (widget.showGroups &&
          c!.group != null &&
          c.group!.displayName != null &&
          c.group!.displayName!.toUpperCase().contains(
                searchController.text.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
    }

    return _filteredList;
  }
}
