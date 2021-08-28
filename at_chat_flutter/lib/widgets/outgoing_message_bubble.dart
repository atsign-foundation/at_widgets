import 'dart:convert';

import 'package:at_chat_flutter/models/message_model.dart';
import 'package:at_chat_flutter/utils/colors.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:flutter/material.dart';

class OutgoingMessageBubble extends StatefulWidget {
  final Message? message;
  final Color color;
  final Color avatarColor;

  const OutgoingMessageBubble(
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
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(30.toHeight),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(10.toWidth),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 165.toWidth),
            child: _buildContentMessage(),
          ),
        ),
        SizedBox(
          width: 15.toWidth,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 45.toFont,
          width: 45.toFont,
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
    );
  }

  Widget _buildContentMessage() {
    if (widget.message?.contentType == MessageContentType.IMAGE) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 165.toWidth),
        child: Image.memory(base64Decode(widget.message?.message ?? '')),
      );
    } else {
      return Text(
        widget.message?.message ?? ' ',
        textAlign: TextAlign.right,
      );
    }
  }
}
