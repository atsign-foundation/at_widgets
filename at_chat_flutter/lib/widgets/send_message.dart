import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class SendMessage extends StatefulWidget {
  final Function? onSend;
  final ValueChanged<String>? messageCallback;
  final Color? sendButtonColor;
  final String? hintText;
  const SendMessage(
      {Key? key,
      this.onSend,
      this.messageCallback,
      this.sendButtonColor,
      this.hintText})
      : super(key: key);
  @override
  _SendMessageState createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  TextEditingController? _sendController;

  @override
  void initState() {
    _sendController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _sendController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.toHeight),
          color: Colors.grey[200]),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _sendController,
              onChanged: (s) {
                widget.messageCallback!(s);
              },
              decoration: InputDecoration.collapsed(
                  hintText: widget.hintText ?? 'Type a message to send',
                  border: InputBorder.none),
            ),
          )),
          IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: widget.sendButtonColor ?? Colors.orange,
              ),
              onPressed: () {
                widget.messageCallback!(_sendController!.text);
                widget.onSend!();
                _sendController!.clear();
              })
        ],
      ),
    );
  }
}
