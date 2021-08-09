import 'package:at_chat_flutter/models/message_model.dart';
import 'package:at_chat_flutter/services/chat_service.dart';
import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_chat_flutter/utils/dialog_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_chat_flutter/widgets/incoming_message_bubble.dart';
import 'package:at_chat_flutter/widgets/outgoing_message_bubble.dart';
import 'package:at_chat_flutter/widgets/send_message.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class ChatScreen extends StatefulWidget {
  final double? height;
  final bool isScreen;
  final Color outgoingMessageColor;
  final Color incomingMessageColor;
  final Color senderAvatarColor;
  final Color receiverAvatarColor;
  final String title;
  final String? hintText;

  /// Widget to display chats as a screen or a bottom sheet.
  /// [height] specifies the height of bottom sheet/screen,
  /// [isScreen] toggles the screen behaviour to adapt for screen or bottom sheet,
  /// [outgoingMessageColor] defines the color of outgoing message color,
  /// [incomingMessageColor] defines the color of incoming message color.
  /// [title] specifies the title text to be displayed.
  /// [hintText] specifies the hint text to be displayed in the input box.

  const ChatScreen(
      {Key? key,
      this.height,
      this.isScreen = false,
      this.outgoingMessageColor = CustomColors.outgoingMessageColor,
      this.incomingMessageColor = CustomColors.incomingMessageColor,
      this.senderAvatarColor = CustomColors.defaultColor,
      this.receiverAvatarColor = CustomColors.defaultColor,
      this.title = 'Messages',
      this.hintText})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Widget> messageList = [];
  String? message;
  ScrollController? _scrollController;
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _chatService = ChatService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _chatService.getChatHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.toHeight),
        topRight: Radius.circular(10.toHeight),
      ),
      child: Container(
        height: widget.height ?? SizeConfig().screenHeight * 0.8,
        margin: widget.isScreen
            ? const EdgeInsets.all(0.0)
            : const EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.toHeight),
            topRight: Radius.circular(10.toHeight),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black87
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          children: [
            (widget.isScreen)
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.title,
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(
                                color: Color(0xffFC7B30), fontSize: 14),
                          ),
                        ),
                      )
                    ],
                  ),
            Expanded(
                child: StreamBuilder<List<Message>>(
                    stream: _chatService.chatStream,
                    initialData: _chatService.chatHistory,
                    builder: (context, snapshot) {
                      return (snapshot.connectionState ==
                              ConnectionState.waiting)
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : (snapshot.data == null || snapshot.data!.isEmpty)
                              ? Center(
                                  child: Text('No chat history found'),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      child: snapshot.data![index].type ==
                                              MessageType.INCOMING
                                          ? IncomingMessageBubble(
                                              message: snapshot.data![index],
                                              color:
                                                  widget.incomingMessageColor,
                                              avatarColor:
                                                  widget.senderAvatarColor,
                                            )
                                          : OutgoingMessageBubble(
                                              (id) async {
                                                final confirmed = await confirm(
                                                  this.context,
                                                  title: 'Confirm Dialog',
                                                  message: 'Do you want to delete this message?',
                                                  positiveActionTitle: 'Yes',
                                                  negativeActionTitle: 'No',
                                                );
                                                if (!confirmed) return;

                                                var result = await _chatService
                                                    .deleteSelectedMessage(id);
                                                var message = result
                                                    ? 'Message is deleted'
                                                    : 'Failed to delete';
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            Text(message)));
                                              },
                                              message: snapshot.data![index],
                                              color:
                                                  widget.outgoingMessageColor,
                                              avatarColor:
                                                  widget.receiverAvatarColor,
                                            ),
                                    );
                                  });
                    })),
            SendMessage(
              messageCallback: (s) {
                message = s;
              },
              hintText: widget.hintText,
              onSend: () async {
                if (message != '') {
                  await _chatService.sendMessage(message);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
