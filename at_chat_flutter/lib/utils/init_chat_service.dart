// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_chat_flutter/services/chat_service.dart';

void initializeChatService(AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  ChatService()
      .initChatService(atClientInstance, currentAtSign, rootDomain, rootPort);
}

void setChatWithAtSign(String? atsign,
    {bool isGroup = false, String? groupId, List<String>? groupMembers}) {
  ChatService().setAtsignToChatWith(atsign, isGroup, groupId, groupMembers);
}

void disposeContactsControllers() {
  ChatService().disposeControllers();
}

Future<bool> deleteMessages() async {
  return await ChatService().deleteMessages();
}
