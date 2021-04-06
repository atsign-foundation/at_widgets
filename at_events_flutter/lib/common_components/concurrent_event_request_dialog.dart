import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ConcurrentEventRequest extends StatefulWidget {
  final String reqEvent,
      reqInvitedPeopleCount,
      reqTimeAndDate,
      currentEvent,
      currentEventTimeAndDate;
  final EventNotificationModel concurrentEvent;
  ConcurrentEventRequest(
      {this.reqEvent,
      this.reqInvitedPeopleCount,
      this.reqTimeAndDate,
      this.currentEvent,
      this.currentEventTimeAndDate,
      @required this.concurrentEvent});

  @override
  _ConcurrentEventRequestState createState() => _ConcurrentEventRequestState();
}

class _ConcurrentEventRequestState extends State<ConcurrentEventRequest> {
  bool isLoader;
  @override
  void initState() {
    super.initState();
    isLoader = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 5, 10),
        content: Container(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You already have an event scheduled during this hour. Are you sure you want to accept another?',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles().grey16,
                  ),
                  Divider(
                    height: 2,
                  ),
                  SizedBox(height: 15.toHeight),
                  widget.concurrentEvent != null
                      ? Text(widget.concurrentEvent.title,
                          style: CustomTextStyles().black16)
                      : SizedBox(),
                  widget.concurrentEvent != null
                      ? Text(
                          '${timeOfDayToString(widget.concurrentEvent.event.startTime)} on ${dateToString(widget.concurrentEvent.event.date)}',
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 20.toHeight),
                  !isLoader
                      ? CustomButton(
                          onPressed: () async {
                            setState(() {
                              isLoader = true;
                            });
                            await EventService().createEvent(
                                isEventOverlap: true, context: context);
                            if (mounted) {
                              setState(() {
                                isLoader = true;
                              });
                            }
                          },
                          buttonText: 'Yes! Create another',
                          width: 278,
                          height: 48.toHeight,
                          buttonColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? AllColors().Black
                                  : AllColors().WHITE,
                          fontColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? AllColors().WHITE
                                  : AllColors().Black,
                        )
                      : CircularProgressIndicator(),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No! Cancel this',
                      style: CustomTextStyles().black14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
