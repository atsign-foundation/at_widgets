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

  late AtClientManager atClientManager;
  String? rootDomain;
  int? rootPort;
  String? currentAtSign;
  String? chatWithAtSign;
  List<Message> chatHistory = [];
  List<dynamic> chatHistoryMessages = [];
  List<dynamic> chatHistoryMessagesOther = [];
  bool monitorStarted = false;

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
      AtClientManager atClientManagerFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientManager = atClientManagerFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    if (!monitorStarted) {
      AtClientManager.getInstance()
          .notificationService
          .subscribe(
              regex: atClientManager.atClient.getPreferences()!.namespace ?? '')
          .listen((notification) {
        _notificationCallback(notification);
      });
      print('Monitor started');
      monitorStarted = true;
    }
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    var str = await KeychainUtil.getPrivateKey(atsign);
    return str!;
  }

  void _notificationCallback(dynamic notification) async {
    print('notification received: $notification');

    var notificationKey = notification.key;
    var fromAtsign = notification.from;

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
      var message = notification.value;
      var decryptedMessage = await atClientManager.atClient.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
        print('error in decrypting message ${e.errorCode} ${e.errorMessage}');
      });
      print('chat message => $decryptedMessage $fromAtsign');
      chatHistoryMessagesOther =
          json.decode((decryptedMessage) as String) as List;
      chatHistory = interleave(chatHistoryMessages, chatHistoryMessagesOther);
      chatSink.add(chatHistory);
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
            (chatWithAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign!
        ..sharedWith = chatWithAtSign
        ..metadata = Metadata();
      key.metadata?.ccd = true;
      var keyValue = await atClientManager.atClient.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });
      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        chatHistoryMessages = json.decode((keyValue.value) as String) as List;
      } else {
        chatHistoryMessages = [];
      }
      // get received messages
      key.key = storageKey +
          (isGroupChat ? groupChatId! : '') +
          (chatWithAtSign != null ? currentAtSign! : ' ').substring(1);
      key.sharedBy = chatWithAtSign;
      key.sharedWith = currentAtSign!;
      keyValue = await atClientManager.atClient.get(key).catchError((e) {
        print(
            'error in getting other history ${e.errorCode} ${e.errorMessage}');
      });
      if (keyValue != null && keyValue.value != null) {
        chatHistoryMessagesOther =
            json.decode((keyValue.value) as String) as List;
      } else {
        chatHistoryMessagesOther = [];
      }

      chatHistory = interleave(chatHistoryMessages, chatHistoryMessagesOther);
      chatSink.add(chatHistory);
    } catch (error) {
      print('Error in getting chat -> $error');
      chatSink.add(chatHistory);
    }
  }

  List<Message> interleave<T>(List a, List b) {
    List result = [];
    final ita = a.iterator;
    final itb = b.iterator;
    bool hasa = ita.moveNext();
    bool hasb = itb.moveNext();
    var valueA, valueB;
    while (hasa | hasb) {
      if (hasa && hasb) {
        valueA = Message.fromJson(ita.current);
        valueB = Message.fromJson(itb.current);
        valueB.type = MessageType.INCOMING;
        if (valueA.time > valueB.time) {
          result.add(valueA);
          hasa = ita.moveNext();
        } else {
          result.add(valueB);
          hasb = itb.moveNext();
        }
      } else if (hasa) {
        valueA = Message.fromJson(ita.current);
        result.add(valueA);
        while (hasa = ita.moveNext()) {
          valueA = Message.fromJson(ita.current);
          result.add(valueA);
        }
      } else if (hasb) {
        valueB = Message.fromJson(itb.current);
        valueB.type = MessageType.INCOMING;
        result.add(valueB);
        while (hasb = itb.moveNext()) {
          valueB = Message.fromJson(itb.current);
          valueB.type = MessageType.INCOMING;
          result.add(valueB);
        }
      }
    }
    List<Message> finalResult = List<Message>.from(result);
    return finalResult;
  }

  Future<void> setChatHistory(Message message) async {
    try {
      var key = AtKey()
        ..key = storageKey +
            (isGroupChat ? groupChatId! : '') +
            (chatWithAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign!
        ..sharedWith = chatWithAtSign
        ..metadata = Metadata();
      key.metadata?.ccd = true;
      key.metadata?.ttr = -1;

      chatHistory.insert(0, message);
      chatSink.add(chatHistory);
      chatHistoryMessages.insert(0, message.toJson());
      await atClientManager.atClient.put(key, json.encode(chatHistoryMessages));
    } catch (e) {
      print('Error in setting chat => $e');
    }
  }

  Future<void> sendMessage(String? message) async {
    await setChatHistory(Message(
        id: '${currentAtSign}_${DateTime.now().millisecondsSinceEpoch}',
        message: message,
        sender: currentAtSign,
        time: DateTime.now().millisecondsSinceEpoch,
        type: MessageType.OUTGOING));

    // TODO: change logic for group chat to accomodate delete
    // var atKey = AtKey()
    //   ..metadata = Metadata()
    //   ..metadata?.ttr = -1
    //   ..key = chatKey +
    //       (isGroupChat ? groupChatId! : '') +
    //       DateTime.now().millisecondsSinceEpoch.toString();
    // if (isGroupChat) {
    //   await Future.forEach(groupChatMembers!, (dynamic member) async {
    //     if (member != currentAtSign) {
    //       atKey.sharedWith = member;
    //       var result = await atClientInstance.put(atKey, message);
    //       print('send notification for groupChat => $result');
    //     }
    //   });
    // } else {
    //   atKey.sharedWith = chatWithAtSign;
    //   var result = await atClientInstance.put(atKey, message);
    //   print('send notification => $result');
    // }
  }

  // deletes self owned messages only
  Future<bool> deleteMessages() async {
    var key = AtKey()
      ..key = storageKey +
          (isGroupChat ? groupChatId! : '') +
          (chatWithAtSign ?? ' ').substring(1)
      ..sharedBy = currentAtSign!
      ..sharedWith = chatWithAtSign
      ..metadata = Metadata();
    key.metadata?.ccd = true;

    try {
      chatHistoryMessages = [];
      var result = await atClientManager.atClient
          .put(key, json.encode(chatHistoryMessages));
      await getChatHistory();
      return result;
    } catch (e) {
      print('error in deleting => $e');
      return false;
    }
  }

  Future<bool> deleteSelectedMessage(String? id) async {
    var key = AtKey()
      ..key = storageKey +
          (isGroupChat ? groupChatId! : '') +
          (chatWithAtSign ?? ' ').substring(1)
      ..sharedBy = currentAtSign!
      ..sharedWith = chatWithAtSign
      ..metadata = Metadata();
    key.metadata?.ccd = true;

    try {
      chatHistoryMessages.removeWhere((e) {
        var message = Message.fromJson(e);
        return message.id == id;
      });
      var result = await atClientManager.atClient
          .put(key, json.encode(chatHistoryMessages));
      await getChatHistory();
      return result;
    } catch (e) {
      print('error in deleting => $e');
      return false;
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
          var result = await atClientManager.atClient.put(atKey, base64Image);
          print('send notification for groupChat => $result');
        }
      });
    } else {
      atKey.sharedWith = chatWithAtSign;
      var result = await atClientManager.atClient.put(atKey, base64Image);
      print('send notification => $result');
    }
  }
}
