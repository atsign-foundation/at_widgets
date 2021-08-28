/// A service to handle save and retrieve operation on chat

import 'dart:async';
import 'dart:convert';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';
import 'package:at_chat_flutter/models/message_model.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;

  final String storageKey = 'chathistory.';
  final String chatKey = 'chat';
  final String chatImageKey = 'chatimg';

  late AtClientImpl atClientInstance;
  String? rootDomain;
  int? rootPort;
  String? currentAtSign;
  String? chatWithAtSign;
  List<Message> chatHistory = <Message>[];
  List<dynamic>? chatHistoryMessages = <dynamic>[];

  // in case of group chat
  bool isGroupChat = false;
  String? groupChatId;
  List<String>? groupChatMembers = <String>[];

  StreamController<List<Message>> chatStreamController = StreamController<List<Message>>.broadcast();
  Sink<List<Message>> get chatSink => chatStreamController.sink;
  Stream<List<Message>> get chatStream => chatStreamController.stream;

  void disposeControllers() {
    chatStreamController.close();
  }

  Future<void> initChatService(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      String rootDomainFromApp, int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    String privateKey = await getPrivateKey(currentAtSign!);
    await atClientInstance.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    String? str = await atClientInstance.getPrivateKey(atsign);
    return str!;
  }

  Future<void> _notificationCallback(dynamic notification) async {
    notification = notification.replaceFirst('notification:', '');
    Map<String, dynamic> responseJson = jsonDecode(notification);
    String notificationKey = responseJson['key']!;
    String fromAtsign = responseJson['from']!;

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if (((notificationKey.startsWith(chatKey) || notificationKey.startsWith(chatImageKey)) &&
            fromAtsign == chatWithAtSign) ||
        (isGroupChat &&
            (notificationKey.startsWith(chatKey + groupChatId!) ||
                notificationKey.startsWith(chatImageKey + groupChatId!)) &&
            groupChatMembers!.contains(fromAtsign))) {
      String? message = responseJson['value'];
      String decryptedMessage =
          await atClientInstance.encryptionService!.decrypt(message!, fromAtsign).catchError((dynamic e) {
        print('error in decrypting message ${e.errorCode} ${e.errorMessage}');
      });
      print('chat message => $decryptedMessage $fromAtsign');
      if (notificationKey.startsWith(chatImageKey)) {
        await setChatHistory(Message(
            message: decryptedMessage,
            sender: fromAtsign,
            time: responseJson['epochMillis'],
            type: MessageType.INCOMING,
            contentType: MessageContentType.IMAGE));
      } else {
        await setChatHistory(Message(
            message: decryptedMessage,
            sender: fromAtsign,
            time: responseJson['epochMillis'],
            type: MessageType.INCOMING));
      }
    }
  }

  void setAtsignToChatWith(String? chatWithAtSignFromApp, bool isGroup, String? groupId, List<String>? groupMembers) {
    if (isGroup) {
      isGroupChat = isGroup;
      groupChatId = groupId;
      groupChatMembers = groupMembers;
    } else {
      // ignore: unnecessary_null_comparison
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
  }

  Future<void> getChatHistory({String? atsign}) async {
    try {
      chatHistory = <Message>[];
      AtKey key = AtKey()
        ..key = storageKey + (isGroupChat ? groupChatId! : '') + (atsign ?? chatWithAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign!
        ..metadata = Metadata();

      AtValue keyValue = await atClientInstance.get(key).catchError((dynamic e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        chatHistoryMessages = json.decode(keyValue.value.toString());
        for (String value in chatHistoryMessages!) {
          Message message = Message.fromJson((value));
          chatHistory.insert(0, message);
        }
        chatSink.add(chatHistory);
      } else {
        chatHistoryMessages = <Message>[];
        chatSink.add(chatHistory);
      }
      String referenceKey = (isGroupChat ? groupChatId! : '') +
          (chatHistory.isEmpty ? '' : chatHistory[0].time.toString()) +
          currentAtSign!;
      await checkForMissedMessages(referenceKey);
    } catch (error) {
      print('Error in getting chat -> $error');
    }
  }

  Future<void> checkForMissedMessages(String referenceKey) async {
    List<String> result = await atClientInstance
        .getKeys(
            sharedBy: chatWithAtSign, sharedWith: currentAtSign!, regex: chatKey + (isGroupChat ? groupChatId! : ''))
        .catchError((dynamic e) {
      print('error in checkForMissedMessages:getKeys ${e.toString()}');
    });
    await Future.forEach(result, (dynamic key) async {
      if (key.startsWith(chatImageKey)) {
        if (referenceKey.compareTo(key.substring(7)) == -1 && !key.startsWith(storageKey)) {
          print('missed key - $key');
          await getMissingKey(key);
        }
      } else {
        if (referenceKey.compareTo(key.substring(4)) == -1 && !key.startsWith(storageKey)) {
          print('missed key - $key');
          await getMissingKey(key);
        }
      }
    });
  }

  Future<void> getMissingKey(String missingKey) async {
    AtKey missingAtkey = AtKey.fromString(missingKey);
    AtValue result = await atClientInstance.get(missingAtkey).catchError((dynamic e) {
      print('error in getMissingKey:get ${e.toString()}');
    });
    // ignore: unnecessary_null_comparison
    if (result != null) {
      if (missingKey.startsWith(chatImageKey)) {
        await setChatHistory(Message(
            message: result.value,
            sender: chatWithAtSign ?? missingAtkey.sharedBy,
            time: int.parse(missingKey
                .replaceFirst(chatWithAtSign ?? '', '')
                .replaceFirst(chatImageKey + (isGroupChat ? groupChatId! : ''), '')
                .split('.')[0]),
            type: MessageType.INCOMING,
            contentType: MessageContentType.IMAGE));
      } else {
        await setChatHistory(Message(
            message: result.value,
            sender: chatWithAtSign ?? missingAtkey.sharedBy,
            time: int.parse(missingKey
                .replaceFirst(chatWithAtSign ?? '', '')
                .replaceFirst(chatKey + (isGroupChat ? groupChatId! : ''), '')
                .split('.')[0]),
            type: MessageType.INCOMING));
      }
    }
  }

  Future<void> setChatHistory(Message message) async {
    try {
      AtKey key = AtKey()
        ..key = storageKey + (isGroupChat ? groupChatId! : '') + (chatWithAtSign ?? ' ').substring(1)
        ..metadata = Metadata();

      chatHistory.insert(0, message);
      chatSink.add(chatHistory);
      chatHistoryMessages!.add(message.toJson());
      await atClientInstance.put(key, json.encode(chatHistoryMessages));
    } catch (e) {
      print('Error in setting chat => $e');
    }
  }

  Future<void> sendMessage(String? message) async {
    await setChatHistory(Message(
        message: message,
        sender: currentAtSign,
        time: DateTime.now().millisecondsSinceEpoch,
        type: MessageType.OUTGOING));

    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata?.ttr = -1
      ..key = chatKey + (isGroupChat ? groupChatId! : '') + DateTime.now().millisecondsSinceEpoch.toString();
    if (isGroupChat) {
      await Future.forEach(groupChatMembers!, (dynamic member) async {
        if (member != currentAtSign) {
          atKey.sharedWith = member;
          bool result = await atClientInstance.put(atKey, message);
          print('send notification for groupChat => $result');
        }
      });
    } else {
      atKey.sharedWith = chatWithAtSign;
      bool result = await atClientInstance.put(atKey, message);
      print('send notification => $result');
    }
  }

  Future<void> sendImageFile(File file) async {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    await setChatHistory(Message(
      message: base64Image,
      sender: currentAtSign,
      time: DateTime.now().millisecondsSinceEpoch,
      type: MessageType.OUTGOING,
      contentType: MessageContentType.IMAGE,
    ));

    Metadata metadata = Metadata();
    AtKey atKey = AtKey()
      ..metadata = metadata
      ..metadata?.ttr = -1
      ..key = chatImageKey + (isGroupChat ? groupChatId! : '') + DateTime.now().millisecondsSinceEpoch.toString();
    if (isGroupChat) {
      await Future.forEach(groupChatMembers!, (dynamic member) async {
        if (member != currentAtSign) {
          atKey.sharedWith = member;
          bool result = await atClientInstance.put(atKey, base64Image);
          print('send notification for groupChat => $result');
        }
      });
    } else {
      atKey.sharedWith = chatWithAtSign;
      bool result = await atClientInstance.put(atKey, base64Image);
      print('send notification => $result');
    }
  }
}
