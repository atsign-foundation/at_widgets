import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_chat_flutter/services/chat_service.dart';

void initializeChatService(AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  ChatService()
      .initChatService(atClientInstance, currentAtSign, rootDomain, rootPort);
}

void setChatWithAtSign(String atsign) {
  ChatService().setAtsignToChatWith(atsign);
}

void checkMonitorConnection() {
  ChatService().checkOutboundConnnection();
}

void disposeContactsControllers() {
  ChatService().disposeControllers();
}
