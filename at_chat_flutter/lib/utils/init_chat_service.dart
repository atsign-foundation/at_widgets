// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_chat_flutter/services/chat_service.dart';

void initializeChatService(AtClientImpl atClientInstance, String currentAtSign,
    {String rootDomain = 'root.atsign.wtf', int rootPort = 64}) {
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
