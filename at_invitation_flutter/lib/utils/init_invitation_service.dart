import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_invitation_flutter/services/invitation_service.dart';
import 'package:at_invitation_flutter/widgets/share_dialog.dart';

void initializeInvitationService(
    {@required GlobalKey<NavigatorState>? navkey,
    @required AtClientImpl? atClientInstance,
    @required String? currentAtSign,
    @required String? webPage,
    rootDomain = 'root.atsign.wtf',
    rootPort = 64}) {
  InvitationService().initInvitationService(
      navkey, atClientInstance, currentAtSign, webPage, rootDomain, rootPort);
}

void shareAndInvite(BuildContext context, String jsonData) {
  InvitationService().shareAndinvite(context, jsonData);
}

fetchInviteData(BuildContext context, String data, String atsign) {
  print('fetchInviteData $data $atsign');
  InvitationService().fetchInviteData(context, data, atsign);
}
