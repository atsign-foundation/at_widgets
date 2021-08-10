import 'package:at_chat_flutter/models/message_model.dart';
import 'package:at_chat_flutter/services/chat_service.dart';
import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_chat_flutter/utils/dialog_utils.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:flutter/material.dart';

class OutgoingMessageBubble extends StatefulWidget {
  final Message? message;
  final Color color;
  final Color avatarColor;
  final Function(String?) deleteCallback;

  const OutgoingMessageBubble(this.deleteCallback,
      {Key? key,
      this.message,
      this.color = CustomColors.outgoingMessageColor,
      this.avatarColor = CustomColors.defaultColor})
      : super(key: key);

  @override
  _OutgoingMessageBubbleState createState() => _OutgoingMessageBubbleState();
}

class _OutgoingMessageBubbleState extends State<OutgoingMessageBubble> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onLongPress: () {
        showBottomSheetDialog(context, () {
          widget.deleteCallback(widget.message?.id);
        });
      },
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(16.toHeight),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 165.toWidth),
              child: Text(
                widget.message?.message ?? ' ',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SizedBox(
            width: 8.toWidth,
          ),
          Container(
            height: 24.toFont,
            width: 24.toFont,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45.toWidth),
            ),
            child: ContactInitial(
              initials: widget.message?.sender ?? '@',
            ),
          ),
          SizedBox(
            width: 20.toWidth,
          )
        ],
      ),
    );
  }
}
