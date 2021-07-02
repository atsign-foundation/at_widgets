import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class EventsMapScreen extends StatefulWidget {
  final EventNotificationModel event;
  const EventsMapScreen(this.event, {Key key}) : super(key: key);

  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<EventsMapScreen> {
  @override
  Widget build(BuildContext context) {
    var tags = widget.event.group.members.elementAt(0).tags;
    var _receiver = widget.event.group.members.elementAt(0).atSign;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 100),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              '${widget.event.atsignCreator}: ${widget.event.lat}, ${widget.event.long}',
              style: CustomTextStyles().black18,
            ),
            Text(
              "$_receiver: ${tags['lat']}, ${tags['long']}",
              style: CustomTextStyles().black16,
            )
            // ListView.builder(itemBuilder: (context, index) {
            //   return Text("${tags['lat']}, ${tags['long']}");
            // }),
          ],
        ),
      ),
    );
  }
}
