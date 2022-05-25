import 'package:at_dude_flutter/models/dude_model.dart';
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class DudeBubble extends StatefulWidget {
  DudeBubble({
    Key? key,
    required this.dude,
  }) : super(key: key);

  final DudeModel dude;

  @override
  State<DudeBubble> createState() => _DudeBubbleState();
}

class _DudeBubbleState extends State<DudeBubble> {
  late DudeService _dudeService;
  final AudioCache audioPlayer = AudioCache();
  @override
  void initState() {
    _dudeService = DudeService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.dude.sender ==
        _dudeService.atClientManager.atClient.getCurrentAtSign();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.dude.sender,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Theme.of(context).colorScheme.primary : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: IconButton(
                        onPressed: () async {
                          await audioPlayer.play('audios/dude.wav');
                          Provider.of<DudeService>(context, listen: false)
                              .deleteSingleDude(widget.dude);
                        },
                        icon: const Icon(Icons.play_arrow_outlined)),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dude.dude,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          'To:' + widget.dude.receiver,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 10.0,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
