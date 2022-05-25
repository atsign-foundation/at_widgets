import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import '../models/models.dart';
import 'widgets.dart';

class FavoriteContacts extends StatefulWidget {
  final DudeModel dude;
  final Function updateIsLoading;
  const FavoriteContacts(
      {required this.dude, required this.updateIsLoading, Key? key})
      : super(key: key);

  @override
  State<FavoriteContacts> createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  late DudeService _dudeService;
  @override
  void initState() {
    _dudeService = DudeService();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await _dudeService.getCurrentAtsignProfileImage();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _handleSendDudeToContact(
        {required DudeModel dude,
        required String contactAtsign,
        required BuildContext context}) async {
      widget.updateIsLoading(true);
      _dudeService.putDude(dude, contactAtsign).then((value) {
        if (value) {
          widget.updateIsLoading(false);
          SnackBars.notificationSnackBar(
              content: 'Dude successfully sent', context: context);
        } else {
          widget.updateIsLoading(false);
          SnackBars.errorSnackBar(
              content: 'Something went wrong, please try again',
              context: context);
        }
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Favorite Dudes',
              style: Theme.of(context).textTheme.headline2,
            ),
            IconButton(
                onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const AddContactDialog(),
                    ),
                icon: const Icon(Icons.add))
          ],
        ),
        Flexible(
            child: _dudeService.selectedContacts == null ||
                    _dudeService.selectedContacts!.isEmpty
                ? const Text('No Contacts Available')
                : ListView.builder(
                    itemCount: _dudeService.selectedContacts!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (_dudeService.selectedContacts!.isEmpty ||
                          _dudeService.selectedContacts == null) {
                        return const Text('No Contacts Available');
                      } else {
                        return GestureDetector(
                          onTap: () {
                            if (widget.dude.dude.isEmpty) {
                              SnackBars.notificationSnackBar(
                                  content: 'No duuude to send',
                                  context: context);
                            } else {
                              _handleSendDudeToContact(
                                  dude: widget.dude,
                                  contactAtsign: _dudeService
                                      .selectedContacts![index]!.atSign!,
                                  context: context);
                            }
                          },
                          child: CircularContacts(
                            contact: _dudeService.selectedContacts![index],
                            onCrossPressed: () {},
                          ),
                        );
                      }
                    })),
      ],
    );
  }
}
