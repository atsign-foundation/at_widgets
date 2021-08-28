import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_invitation_flutter/services/invitation_service.dart';

void initializeInvitationService(
    {required GlobalKey<NavigatorState>? navkey,
    required AtClientImpl? atClientInstance,
    required String? currentAtSign,
    required String? webPage,
    String rootDomain = 'root.atsign.wtf',
    int rootPort = 64}) {
  InvitationService().initInvitationService(
      navkey, atClientInstance, currentAtSign, webPage, rootDomain, rootPort);
}

Future<void> shareAndInvite(BuildContext context, String jsonData) async {
  await InvitationService().shareAndinvite(context, jsonData);
}

Future<void> fetchInviteData(BuildContext context, String data, String atsign) async {
  print('fetchInviteData $data $atsign');
  await InvitationService().fetchInviteData(context, data, atsign);
}
