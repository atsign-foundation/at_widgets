import 'package:at_chat_flutter/models/message_model.dart';
import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:flutter/material.dart';

class IncomingMessageBubble extends StatefulWidget {
  final Message? message;
  final Color color;
  final Color avatarColor;

  const IncomingMessageBubble(
      {Key? key,
      this.message,
      this.color = CustomColors.incomingMessageColor,
      this.avatarColor = CustomColors.defaultColor})
      : super(key: key);
  @override
  _IncomingMessageBubbleState createState() => _IncomingMessageBubbleState();
}

class _IncomingMessageBubbleState extends State<IncomingMessageBubble> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.toWidth,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 45.toFont,
          width: 45.toFont,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45.toWidth),
          ),
          child: ContactInitial(
            initials: widget.message?.sender?.substring(1, 3) ?? '@',
            backgroundColor: widget.avatarColor,
          ),
        ),
        SizedBox(
          width: 15.toWidth,
        ),
        Container(
          padding: EdgeInsets.all(30.toHeight),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(10.toWidth),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 170.toWidth),
            child: Text(
              widget.message?.message ?? ' ',
              textAlign: TextAlign.right,
              maxLines: 3,
            ),
          ),
        ),
      ],
    );
  }
}
