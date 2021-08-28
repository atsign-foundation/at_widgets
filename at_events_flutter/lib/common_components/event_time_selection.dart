import 'package:at_events_flutter/common_components/text_tile.dart';
import 'package:at_events_flutter/models/enums_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

import 'invite_card.dart';

class EventTimeSelection extends StatefulWidget {
  final String? title;
  final List<String> options;
  final EventNotificationModel? eventNotificationModel;
  final ValueChanged<dynamic>? onSelectionChanged;
  final bool isStartTime;

  EventTimeSelection(
      {this.title,
      required this.eventNotificationModel,
      this.onSelectionChanged,
      required this.options,
      this.isStartTime = false});
  @override
  _EventTimeSelectionState createState() => _EventTimeSelectionState();
}

class _EventTimeSelectionState extends State<EventTimeSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          InviteCard(
            event: widget.eventNotificationModel!.title,
            timeAndDate:
                '${timeOfDayToString(widget.eventNotificationModel!.event!.startTime!)} on ${dateToString(widget.eventNotificationModel!.event!.date!)}',
            atSign: widget.eventNotificationModel!.atsignCreator,
            memberCount:
                '+${widget.eventNotificationModel!.group!.members!.length}',
            isStartTime: widget.isStartTime,
          ),
          const SizedBox(height: 10),
          const Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.title != null
                    ? Text(widget.title!, style: CustomTextStyles().grey16)
                    : const SizedBox(),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemCount: widget.options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            switch (index) {
                              case 0:
                                widget.onSelectionChanged!(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.TWO_HOURS
                                    : LOC_END_TIME_ENUM.TEN_MIN);
                                break;
                              case 1:
                                widget.onSelectionChanged!(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.SIXTY_MIN
                                    : LOC_END_TIME_ENUM
                                        .AFTER_EVERY_ONE_REACHED);
                                break;
                              case 2:
                                widget.onSelectionChanged!(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.THIRTY_MIN
                                    : LOC_END_TIME_ENUM.AT_EOD);
                                break;
                            }
                          },
                          child: TextTile(title: widget.options[index]),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
