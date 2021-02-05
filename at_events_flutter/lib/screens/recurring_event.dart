import 'dart:convert';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_events_flutter/common_components/custom_heading.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class RecurringEvent extends StatefulWidget {
  @override
  _RecurringEventState createState() => _RecurringEventState();
}

class _RecurringEventState extends State<RecurringEvent> {
  List<String> repeatOccurance;
  List<String> occursOnOptions;
  bool isRepeatEveryWeek;
  EventNotificationModel eventData;

  @override
  void initState() {
    super.initState();
    repeatOccurance = repeatOccuranceOptions;
    occursOnOptions = occursOnWeekOptions;
    eventData = EventNotificationModel.fromJson(jsonDecode(
        EventNotificationModel.convertEventNotificationToJson(
            EventService().eventNotificationModel)));
    if (eventData.event.repeatCycle != null) {
      if (eventData.event.repeatCycle == RepeatCycle.MONTH)
        isRepeatEveryWeek = false;
      else if (eventData.event.repeatCycle == RepeatCycle.WEEK)
        isRepeatEveryWeek = true;
    } else {
      isRepeatEveryWeek = false;
      eventData.event.repeatCycle = RepeatCycle.MONTH;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.8,
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomHeading(heading: 'Recurring event', action: 'Cancel'),
            SizedBox(height: 25),
            Text('Repeat every', style: CustomTextStyles().greyLabel14),
            SizedBox(height: 6.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomInputField(
                  width: 155,
                  height: 50,
                  hintText: 'repeat cycle',
                  icon: Icons.keyboard_arrow_down,
                  initialValue: eventData.event.repeatDuration != null
                      ? eventData.event.repeatDuration.toString()
                      : '',
                  value: (val) {
                    if (val.trim().length > 0) {
                      int repeatCycle = int.parse(val);
                      eventData.event.repeatDuration = repeatCycle;
                    } else
                      eventData.event.repeatDuration = null;
                    print('repeat cycle:${eventData.event.repeatDuration}');
                  },
                ),
                Container(
                  color: AllColors().INPUT_GREY_BACKGROUND,
                  width: 155,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButton(
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down),
                    underline: SizedBox(),
                    elevation: 0,
                    dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
                    value: (eventData.event.repeatCycle != null)
                        ? eventData.event.repeatCycle == RepeatCycle.WEEK
                            ? 'Week'
                            : eventData.event.repeatCycle == RepeatCycle.MONTH
                                ? 'Month'
                                : null
                        : null,
                    hint: Text("Select Category"),
                    items: repeatOccurance.map((String option) {
                      return new DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String selectedOption) {
                      switch (selectedOption) {
                        case 'Week':
                          eventData.event.repeatCycle = RepeatCycle.WEEK;
                          isRepeatEveryWeek = true;
                          break;

                        case 'Month':
                          eventData.event.repeatCycle = RepeatCycle.MONTH;
                          isRepeatEveryWeek = false;
                          break;
                      }

                      setState(() {});
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 25.toHeight),
            Text('Occurs on', style: CustomTextStyles().greyLabel14),
            SizedBox(height: 6.toHeight),
            isRepeatEveryWeek
                ? Container(
                    color: AllColors().INPUT_GREY_BACKGROUND,
                    width: 330.toWidth,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: DropdownButton(
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down),
                      underline: SizedBox(),
                      elevation: 0,
                      dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
                      value: eventData.event.occursOn != null
                          ? getWeekString(eventData.event.occursOn)
                          : null,
                      hint: Text("Occurs on"),
                      items: occursOnOptions.map((String option) {
                        return new DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String selectedOption) {
                        Week weekday = getWeekEnum(selectedOption);
                        if (weekday != null) {
                          eventData.event.occursOn = weekday;
                        }

                        print(eventData.event.occursOn);

                        setState(() {});
                      },
                    ),
                  )
                : CustomInputField(
                    width: 330.toWidth,
                    height: 50,
                    isReadOnly: true,
                    hintText: 'Occurs on',
                    icon: Icons.access_time,
                    initialValue: eventData.event.date != null
                        ? dateToString(eventData.event.date)
                        : '',
                    onTap: () async {
                      final DateTime datePicked = await showDatePicker(
                        context: context,
                        initialDate: (eventData.event.date != null)
                            ? eventData.event.date
                            : DateTime.now(),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      );

                      if (datePicked != null) {
                        eventData.event.date = datePicked;
                        setState(() {});
                      }
                    },
                    value: (val) {},
                  ),
            SizedBox(height: 25.toHeight),
            Text('Select a time', style: CustomTextStyles().greyLabel14),
            SizedBox(height: 6.toHeight),
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
                      eventData.event.startTime = timePicked;
                      setState(() {});
                    }
                  },
                ),
                CustomInputField(
                  width: 155,
                  height: 50,
                  isReadOnly: true,
                  hintText: 'Stop',
                  icon: Icons.access_time,
                  initialValue: eventData.event.endTime != null
                      ? timeOfDayToString(eventData.event.endTime)
                      : '',
                  onTap: () async {
                    if (eventData.event.startTime == null) {
                      CustomToast().show('select start time first', context);
                      return;
                    }
                    final TimeOfDay timePicked = await showTimePicker(
                      context: context,
                      initialTime: eventData.event.endTime != null
                          ? eventData.event.endTime
                          : TimeOfDay.now(),
                    );

                    if (timePicked != null) {
                      if (timePicked != null) if (timePicked.hour +
                              timePicked.minute / 60.0 >
                          eventData.event.startTime.hour +
                              eventData.event.startTime.minute / 60.0)
                        eventData.event.endTime = timePicked;
                      else
                        CustomToast().show(
                            'stop time must be after start time', context);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 25.toHeight),
            Text('Ends On', style: CustomTextStyles().greyLabel14),
            SizedBox(height: 25.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Never',
                    style: Theme.of(context).primaryTextTheme.headline3),
                Radio(
                  groupValue: eventData.event.endsOn,
                  toggleable: true,
                  value: EndsOn.NEVER,
                  onChanged: (value) {
                    eventData.event.endsOn = value;
                    setState(() {});
                  },
                )
              ],
            ),
            SizedBox(height: 6.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('On', style: Theme.of(context).primaryTextTheme.headline3),
                Radio(
                  groupValue: eventData.event.endsOn,
                  toggleable: true,
                  value: EndsOn.ON,
                  onChanged: (value) {
                    eventData.event.endsOn = value;

                    setState(() {});
                  },
                )
              ],
            ),
            SizedBox(height: 6.toHeight),
            CustomInputField(
              width: 330.toWidth,
              height: 50,
              isReadOnly: true,
              hintText: 'Select Date',
              icon: Icons.date_range,
              initialValue: (eventData.event.endEventOnDate != null)
                  ? dateToString(eventData.event.endEventOnDate)
                  : '',
              onTap: () async {
                final DateTime datePicked = await showDatePicker(
                  context: context,
                  initialDate: eventData.event.endEventOnDate != null
                      ? eventData.event.endEventOnDate
                      : DateTime.now(),
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101),
                );

                if (datePicked != null) {
                  eventData.event.endEventOnDate = datePicked;
                  setState(() {});
                }
              },
              value: (value) {},
            ),
            SizedBox(height: 6.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('After',
                    style: Theme.of(context).primaryTextTheme.headline3),
                Radio(
                  groupValue: eventData.event.endsOn,
                  toggleable: true,
                  value: EndsOn.AFTER,
                  onChanged: (value) {
                    eventData.event.endsOn = value;

                    setState(() {});
                  },
                )
              ],
            ),
            SizedBox(height: 6.toHeight),
            CustomInputField(
              width: 330.toWidth,
              height: 50,
              hintText: 'Start',
              // icon: Icons.keyboard_arrow_down,
              initialValue: eventData.event.endEventAfterOccurance != null
                  ? eventData.event.endEventAfterOccurance.toString()
                  : '',
              value: (val) {
                if (val.trim().length > 0) {
                  int occurance = int.parse(val);
                  eventData.event.endEventAfterOccurance = occurance;
                }
              },
            ),
            SizedBox(height: 20),
            Center(
              child: CustomButton(
                onPressed: () {
                  var formValid = EventService()
                      .checForRecurringeDayEventFormValidation(eventData);
                  if (formValid is String) {
                    CustomToast().show(formValid, context);
                    return;
                  }
                  EventService().update(eventData: eventData);
                  Navigator.of(context).pop();
                },
                buttonText: 'Done',
                width: 164.toWidth,
                height: 48.toHeight,
                buttonColor: Theme.of(context).primaryColor,
                fontColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
