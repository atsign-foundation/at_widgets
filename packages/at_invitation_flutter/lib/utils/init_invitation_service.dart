import 'package:flutter/material.dart';
import 'package:at_invitation_flutter/services/invitation_service.dart';

void initializeInvitationService(
    {@required GlobalKey<NavigatorState>? navkey,
    @required String? webPage,
    rootDomain = 'root.atsign.wtf',
    rootPort = 64}) {
  InvitationService()
      .initInvitationService(navkey, webPage, rootDomain, rootPort);
}

/// Invite a contact and create a shared key
void shareAndInvite(BuildContext context, String jsonData) {
  InvitationService().shareAndinvite(context, jsonData);
}

/// fetch the invitation data
fetchInviteData(BuildContext context, String data, String atsign) {
  InvitationService().fetchInviteData(context, data, atsign);
}
