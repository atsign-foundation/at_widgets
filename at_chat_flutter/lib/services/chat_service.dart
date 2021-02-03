/// A service to handle save and retrieve operation on chat

import 'dart:async';
import 'dart:convert';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_chat_flutter/models/message_model.dart';

class ChatService {
  ChatService._();
  static ChatService _instance = ChatService._();
  factory ChatService() => _instance;

  final String storageKey = 'chatHistory.';
  final String chatKey = 'chat';

  AtClientImpl atClientInstance;
  String rootDomain;
  int rootPort;
  String currentAtSign;
  String chatWithAtSign;
  List<Message> chatHistory = [];
  List<dynamic> chatHistoryMessages = [];

  StreamController<List<Message>> chatStreamController =
      StreamController<List<Message>>.broadcast();
  Sink get chatSink => chatStreamController.sink;
  Stream<List<Message>> get chatStream => chatStreamController.stream;

  disposeControllers() {
    chatStreamController.close();
  }

  initChatService(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    String privateKey = await getPrivateKey(currentAtSign);
    atClientInstance.startMonitor(privateKey, _notificationCallback);
    print("Monitor started");
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientInstance.getPrivateKey(atsign);
  }

  void _notificationCallback(dynamic notification) async {
    notification = notification.replaceFirst('notification:', '');
    var responseJson = jsonDecode(notification);
    var notificationKey = responseJson['key'];
    var fromAtsign = responseJson['from'];

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if (notificationKey.startsWith(chatKey) && fromAtsign == chatWithAtSign) {
      var message = responseJson['value'];
      var decryptedMessage = await atClientInstance.encryptionService
          .decrypt(message, fromAtsign)
          .catchError((e) => print(
              "error in decrypting message ${e.errorCode} ${e.errorMessage}"));
      print('chat message => $decryptedMessage $fromAtsign');
      setChatHistory(Message(
          message: decryptedMessage,
          sender: fromAtsign,
          time: responseJson['epochMillis'],
          type: MessageType.INCOMING));
    }
  }

  setAtsignToChatWith(String chatWithAtSignFromApp) {
    if (chatWithAtSignFromApp != null) {
      if (chatWithAtSignFromApp.startsWith('@')) {
        chatWithAtSign = chatWithAtSignFromApp;
      } else {
        chatWithAtSign = '@' + chatWithAtSignFromApp;
      }
    } else {
      chatWithAtSign = '';
    }
  }

  getChatHistory({String atsign}) async {
    try {
      chatHistory = [];
      AtKey key = AtKey()
        ..key = storageKey + (atsign ?? chatWithAtSign)?.substring(1)
        ..sharedBy = currentAtSign
        ..metadata = Metadata();
      var keyValue = await atClientInstance.get(key).catchError(
          (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
      if (keyValue != null && keyValue.value != null) {
        chatHistoryMessages = json.decode((keyValue.value) as String) as List;
        chatHistoryMessages.forEach((value) {
          Message message = Message.fromJson((value));
          chatHistory.insert(0, message);
        });
        chatSink.add(chatHistory);
      } else {
        chatSink.add(chatHistory);
      }
      String referenceKey = chatKey +
          (chatHistory.isEmpty ? '' : chatHistory[0].time.toString()) +
          currentAtSign;
      checkForMissedMessages(referenceKey);
    } catch (error) {
      print('Error in getting chat -> $error');
    }
  }

  checkForMissedMessages(String referenceKey) async {
    var result = await atClientInstance
        .getKeys(
            sharedBy: chatWithAtSign, sharedWith: currentAtSign, regex: chatKey)
        .catchError((e) =>
            print("error in checkForMissedMessages:getKeys ${e.toString()}"));
    result.forEach((key) {
      if (referenceKey.compareTo(key) == -1) {
        print('missed key - $key');
        getMissingKey(key);
      }
    });
  }

  getMissingKey(String missingKey) async {
    AtKey missingAtkey = AtKey.fromString(missingKey);
    var result = await atClientInstance
        .get(missingAtkey)
        .catchError((e) => print("error in getMissingKey:get ${e.toString()}"));
    print('result - $result');
    if (result != null) {
      setChatHistory(Message(
          message: result.value,
          sender: chatWithAtSign,
          time: int.parse(missingKey
              .replaceFirst(chatWithAtSign, '')
              .replaceFirst(chatKey, '')
              .split('.')[0]),
          type: MessageType.INCOMING));
    }
  }

  setChatHistory(Message message) async {
    try {
      AtKey key = AtKey()
        ..key = storageKey + chatWithAtSign.substring(1)
        ..metadata = Metadata();

      chatHistory.insert(0, message);
      chatSink.add(chatHistory);
      chatHistoryMessages.add(message.toJson());
      await atClientInstance.put(key, json.encode(chatHistoryMessages));
    } catch (e) {
      print("Error in setting chat => $e");
    }
  }

  void sendMessage(String message) async {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = chatKey + DateTime.now().millisecondsSinceEpoch.toString()
      ..sharedWith = chatWithAtSign;
    var result = await atClientInstance.put(atKey, message);
    setChatHistory(Message(
        message: message,
        sender: currentAtSign,
        time: DateTime.now().millisecondsSinceEpoch,
        type: MessageType.OUTGOING));
    print("send notification => $result");
  }

}
