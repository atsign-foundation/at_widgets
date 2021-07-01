import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:at_events_flutter/common_components/display_tile.dart';
import 'package:at_events_flutter_example/client_sdk_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class EventList extends StatefulWidget {
  List<EventKeyLocationModel> events;
  EventList(this.events);
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Event list'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                HomeEventService().onEventModelTap(
                    widget.events[index].eventNotificationModel,
                    widget.events[index].haveResponded);
              },
              child: DisplayTile(
                atsignCreator:
                    widget.events[index].eventNotificationModel.atsignCreator,
                number: widget
                    .events[index].eventNotificationModel.group.members.length,
                title: 'Event - ' +
                    widget.events[index].eventNotificationModel.title,
                subTitle: HomeEventService()
                    .getSubTitle(widget.events[index].eventNotificationModel),
                semiTitle: HomeEventService().getSemiTitle(
                    widget.events[index].eventNotificationModel,
                    widget.events[index].haveResponded),
                showRetry:
                    HomeEventService().calculateShowRetry(widget.events[index]),
                onRetryTapped: () {
                  HomeEventService().onEventModelTap(
                      widget.events[index].eventNotificationModel, false);
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: Colors.grey,
            );
          },
          itemCount: widget.events.length),
    );
  }
}
