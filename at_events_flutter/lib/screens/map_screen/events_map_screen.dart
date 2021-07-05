// import 'dart:js';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'events_collapsed_content.dart';

class EventsMapScreenData {
  EventsMapScreenData._();
  static final EventsMapScreenData _instance = EventsMapScreenData._();
  factory EventsMapScreenData() => _instance;

  ValueNotifier<EventNotificationModel> _eventNotifier;

  void moveToEventScreen(EventNotificationModel _eventNotificationModel) {
    _eventNotifier = ValueNotifier(_eventNotificationModel);
    Navigator.push(
      AtEventNotificationListener().navKey.currentContext,
      MaterialPageRoute(
        builder: (context) => _EventsMapScreen(),
      ),
    );
  }

  void updateEventdata(EventNotificationModel _eventNotificationModel) {
    if (_eventNotificationModel.key == _eventNotifier.value.key) {
      _eventNotifier.value = _eventNotificationModel;
    }
  }

  void updateEventdataFromList(List<EventKeyLocationModel> _list) {
    if (_eventNotifier != null) {
      for (var i = 0; i < _list.length; i++) {
        if (_list[i].eventNotificationModel.key == _eventNotifier.value.key) {
          _eventNotifier.value = _list[i].eventNotificationModel;
          break;
        }
      }
    }
  }

  void dispose() {
    _eventNotifier = null;
  }
}

class _EventsMapScreen extends StatefulWidget {
  const _EventsMapScreen({Key key}) : super(key: key);

  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<_EventsMapScreen> {
  final PanelController pc = PanelController();

  @override
  void dispose() {
    EventsMapScreenData().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 100),
        alignment: Alignment.center,
        child: ValueListenableBuilder(
          valueListenable: EventsMapScreenData()._eventNotifier,
          builder: (BuildContext context, EventNotificationModel _event,
              Widget child) {
            var tags = _event.group.members.elementAt(0).tags;
            var _receiver = _event.group.members.elementAt(0).atSign;
            return Stack(
              children: [
                Text(
                  '${_event.atsignCreator}: ${_event.lat}, ${_event.long}',
                  style: CustomTextStyles().black18,
                ),
                Text(
                  "$_receiver: ${tags['lat']}, ${tags['long']}",
                  style: CustomTextStyles().black16,
                ),
                // ListView.builder(itemBuilder: (context, index) {
                //   return Text("${tags['lat']}, ${tags['long']}");
                // }),

                SlidingUpPanel(
                  controller: pc,
                  minHeight: 205.toHeight,
                  maxHeight: 431.toHeight,
                  panel: eventsCollapsedContent(_event),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
