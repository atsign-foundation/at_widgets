import 'dart:convert';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_events_flutter/common_components/custom_heading.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class OneDayEvent extends StatefulWidget {
  @override
  _OneDayEventState createState() => _OneDayEventState();
}

class _OneDayEventState extends State<OneDayEvent> {
  EventNotificationModel eventData = new EventNotificationModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // eventData = cloneEventModel();
    eventData = EventNotificationModel.fromJson(jsonDecode(
        EventNotificationModel.convertEventNotificationToJson(
            EventService().eventNotificationModel)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomHeading(heading: 'One Day Event', action: 'Cancel'),
                    SizedBox(height: 25),
                    Text('Select Date', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    CustomInputField(
                      width: 330.toWidth,
                      height: 50,
                      isReadOnly: true,
                      hintText: 'Select Date',
                      icon: Icons.date_range,
                      initialValue: (eventData.event.date != null)
                          ? dateToString(eventData.event.date)
                          : '',
                      onTap: () async {
                        final DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: (eventData.event.date != null)
                                ? eventData.event.date
                                : DateTime.now(),
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime(2101));

                        if (datePicked != null) {
                          setState(() {
                            eventData.event.date = datePicked;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 25),
                    Text('Select Time', style: CustomTextStyles().greyLabel14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155,
                          height: 50,
                          isReadOnly: true,
                          hintText: 'Start',
                          icon: Icons.access_time,
                          initialValue: eventData.event.startTime != null
                              ? timeOfDayToString(eventData.event.startTime)
                              : '',
                          onTap: () async {
                            final TimeOfDay timePicked = await showTimePicker(
                              context: context,
                              initialTime: eventData.event.startTime != null
                                  ? eventData.event.startTime
                                  : TimeOfDay.now(),
                            );

                            if (timePicked != null) {
                              setState(() {
                                eventData.event.startTime = timePicked;
                              });
                            }
                          },
                        ),
                        CustomInputField(
                            width: 155,
                            height: 50,
                            hintText: 'Stop',
                            isReadOnly: true,
                            icon: Icons.access_time,
                            initialValue: eventData.event.endTime != null
                                ? timeOfDayToString(eventData.event.endTime)
                                : '',
                            onTap: () async {
                              final TimeOfDay timePicked = await showTimePicker(
                                context: context,
                                initialTime: eventData.event.endTime != null
                                    ? eventData.event.endTime
                                    : TimeOfDay.now(),
                              );

                              if (timePicked != null)
                                eventData.event.endTime = timePicked;
                              setState(() {});
                            }),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: CustomButton(
                  onPressed: () {
                    var formValid = EventService()
                        .checForOneDayEventFormValidation(eventData);
                    if (formValid is String) {
                      CustomToast().show(formValid, context);
                      return;
                    }
                    EventService().update(eventData: eventData);
                    Navigator.of(context).pop();
                  },
                  buttonText: 'Done',
                  buttonColor: Theme.of(context).primaryColor,
                  fontColor: Theme.of(context).scaffoldBackgroundColor,
                  width: 164.toWidth,
                  height: 48.toHeight,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
