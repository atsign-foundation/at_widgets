import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:at_chat_flutter/services/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatService extends Mock implements ChatService {}

void main() {
  ChatService mockChatService = MockChatService();
  // group('Chat Screen test', () {
  // chat service is initialized
  // test('Chat service is initialized', () async {
  //   ChatScreen chatScreen = ChatScreen();
  //   expect(chatScreen._chatService, matcher)
  // });
  // });
}
