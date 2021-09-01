/// A service to handle save and retrieve operation on chat
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:at_chat_flutter/models/message_model.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;

  final String storageKey = 'chathistory.';
  final String chatKey = 'chat';
  final String chatImageKey = 'chatimg';

  late AtClient atClientInstance;
  String? rootDomain;
  int? rootPort;
  String? currentAtSign;
  String? chatWithAtSign;
  List<Message> chatHistory = [];
  List<dynamic>? chatHistoryMessages = [];

  // in case of group chat
  bool isGroupChat = false;
  String? groupChatId;
  List<String>? groupChatMembers = [];

  StreamController<List<Message>> chatStreamController =
      StreamController<List<Message>>.broadcast();
  Sink get chatSink => chatStreamController.sink;
  Stream<List<Message>> get chatStream => chatStreamController.stream;

  void disposeControllers() {
    chatStreamController.close();
  }

  void initChatService(
      AtClient atClientInstanceFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    var privateKey = await getPrivateKey(currentAtSign!);
    await atClientInstance.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    var str = await KeychainUtil.getPrivateKey(atsign);
    return str!;
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

    if (((notificationKey.startsWith(chatKey) ||
                notificationKey.startsWith(chatImageKey)) &&
            fromAtsign == chatWithAtSign) ||
        (isGroupChat &&
            (notificationKey.startsWith(chatKey + groupChatId!) ||
                notificationKey.startsWith(chatImageKey + groupChatId!)) &&
            groupChatMembers!.contains(fromAtsign))) {
      var message = responseJson['value'];
      var decryptedMessage = await atClientInstance.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
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

  void setAtsignToChatWith(String? chatWithAtSignFromApp, bool isGroup,
      String? groupId, List<String>? groupMembers) {
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
      chatHistory = [];
      var key = AtKey()
        ..key = storageKey +
            (isGroupChat ? groupChatId! : '') +
            (atsign ?? chatWithAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign!
        ..metadata = Metadata();

      var keyValue = await atClientInstance.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        chatHistoryMessages = json.decode((keyValue.value) as String) as List?;
        chatHistoryMessages!.forEach((value) {
          var message = Message.fromJson((value));
          chatHistory.insert(0, message);
        });
        chatSink.add(chatHistory);
      } else {
        chatHistoryMessages = [];
        chatSink.add(chatHistory);
      }
      var referenceKey = (isGroupChat ? groupChatId! : '') +
          (chatHistory.isEmpty ? '' : chatHistory[0].time.toString()) +
          currentAtSign!;
      await checkForMissedMessages(referenceKey);
    } catch (error) {
      print('Error in getting chat -> $error');
    }
  }

  Future<void> checkForMissedMessages(String referenceKey) async {
    var result = await atClientInstance
        .getKeys(
            sharedBy: chatWithAtSign,
            sharedWith: currentAtSign!,
            regex: chatKey + (isGroupChat ? groupChatId! : ''))
        .catchError((e) {
      print('error in checkForMissedMessages:getKeys ${e.toString()}');
    });
    await Future.forEach(result, (dynamic key) async {
      if (key.startsWith(chatImageKey)) {
        if (referenceKey.compareTo(key.substring(7)) == -1 &&
            !key.startsWith(storageKey)) {
          print('missed key - $key');
          await getMissingKey(key);
        }
      } else {
        if (referenceKey.compareTo(key.substring(4)) == -1 &&
            !key.startsWith(storageKey)) {
          print('missed key - $key');
          await getMissingKey(key);
        }
      }
    });
  }

  Future<void> getMissingKey(String missingKey) async {
    var missingAtkey = AtKey.fromString(missingKey);
    var result = await atClientInstance.get(missingAtkey).catchError((e) {
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
                .replaceFirst(
                    chatImageKey + (isGroupChat ? groupChatId! : ''), '')
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
      var key = AtKey()
        ..key = storageKey +
            (isGroupChat ? groupChatId! : '') +
            (chatWithAtSign ?? ' ').substring(1)
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

    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata?.ttr = -1
      ..key = chatKey +
          (isGroupChat ? groupChatId! : '') +
          DateTime.now().millisecondsSinceEpoch.toString();
    if (isGroupChat) {
      await Future.forEach(groupChatMembers!, (dynamic member) async {
        if (member != currentAtSign) {
          atKey.sharedWith = member;
          var result = await atClientInstance.put(atKey, message);
          print('send notification for groupChat => $result');
        }
      });
    } else {
      atKey.sharedWith = chatWithAtSign;
      var result = await atClientInstance.put(atKey, message);
      print('send notification => $result');
    }
  }

  Future<void> sendImageFile(File file) async {
    List<int> imageBytes = file.readAsBytesSync();
    final base64Image = base64Encode(imageBytes);
    await setChatHistory(Message(
      message: base64Image,
      sender: currentAtSign,
      time: DateTime.now().millisecondsSinceEpoch,
      type: MessageType.OUTGOING,
      contentType: MessageContentType.IMAGE,
    ));

    final metadata = Metadata();
    var atKey = AtKey()
      ..metadata = metadata
      ..metadata?.ttr = -1
      ..key = chatImageKey +
          (isGroupChat ? groupChatId! : '') +
          DateTime.now().millisecondsSinceEpoch.toString();
    if (isGroupChat) {
      await Future.forEach(groupChatMembers!, (dynamic member) async {
        if (member != currentAtSign) {
          atKey.sharedWith = member;
          var result = await atClientInstance.put(atKey, base64Image);
          print('send notification for groupChat => $result');
        }
      });
    } else {
      atKey.sharedWith = chatWithAtSign;
      var result = await atClientInstance.put(atKey, base64Image);
      print('send notification => $result');
    }
  }
}
