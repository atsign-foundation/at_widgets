import 'dart:developer';

import 'package:at_chat_flutter/services/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatService extends Mock implements ChatService {}

void main() {
  ChatService mockChatService = MockChatService();
  group('Chat Screen test: ', () {
    // To test chat history retrieval
    setUp(() {
      reset(mockChatService);
    });

    // Test case to check retrieving chat history is successful
    test('Chat history is retrieved', () {
      when(() => mockChatService.getChatHistory().then((_) async {
            log('Get chat history is successful');
          }));
    });
  });
}
