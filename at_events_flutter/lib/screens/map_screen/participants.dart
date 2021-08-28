import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/src/model/at_contact.dart';
import 'package:at_events_flutter/common_components/custom_heading.dart';
import 'package:at_events_flutter/common_components/display_tile.dart';
import 'package:at_events_flutter/common_components/draggable_symbol.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:flutter/material.dart';

import 'events_map_screen.dart';

class Participants extends StatefulWidget {
  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  List<String?> untrackedAtsigns = <String?>[];

  List<String?> trackedAtsigns = <String?>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ValueListenableBuilder<
          EventNotificationModel?>(
          valueListenable: EventsMapScreenData().eventNotifier!,
          builder: (BuildContext context, EventNotificationModel? _event,
              Widget? child) {
            List<HybridModel>? _locationList = EventsMapScreenData().markers;
            untrackedAtsigns = <String?>[];
            trackedAtsigns = _locationList != null
                ? _locationList.map((HybridModel e) => e.displayName).toList()
                : <String?>[];

            /// for creator
            trackedAtsigns.contains(_event!.atsignCreator)
                ? print('')
                : untrackedAtsigns.add(_event.atsignCreator);

            /// for members
            for(AtContact element in _event.group!.members!) {
                  trackedAtsigns.contains(element.atSign)
                      ? print('')
                      : untrackedAtsigns.add(element.atSign);
                }

            return builder(_locationList!, _event);
          }),
    );
  }

  Widget builder(List<HybridModel> _markers, EventNotificationModel? _event) {
    return Container(
      height: 422.toHeight,
      padding:
          EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DraggableSymbol(),
            CustomHeading(heading: 'Participants', action: 'Close'),
            SizedBox(
              height: 10.toHeight,
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _markers.length,
              itemBuilder: (BuildContext context, int index) {
                return _markers[index].displayName == _event!.venue!.label
                    ? const SizedBox()
                    : DisplayTile(
                        title: _markers[index].displayName ?? '',
                        atsignCreator: _markers[index].displayName,
                        subTitle: null,
                        action: Text(
                          (_markers[index].displayName ==
                                  AtEventNotificationListener().currentAtSign)
                              ? ''
                              : _markers[index].eta!,
                          style: CustomTextStyles().darkGrey14,
                        ),
                      );
              },
              separatorBuilder: (BuildContext context, int index) {
                return _markers[index].displayName != _event!.venue!.label
                    ? const Divider()
                    : const SizedBox();
              },
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: untrackedAtsigns.length,
              itemBuilder: (BuildContext context, int index) {
                return DisplayTile(
                  title: untrackedAtsigns[index] ?? 'user name',
                  atsignCreator: untrackedAtsigns[index],
                  subTitle: null,
                  action: Text(
                    EventsMapScreenData()
                            .exitedAtSigns
                            .contains(untrackedAtsigns[index])
                        ? 'Exited'
                        : ((untrackedAtsigns[index] ==
                                AtEventNotificationListener().currentAtSign)
                            ? ''
                            : (isActionRequired(
                                    untrackedAtsigns[index], _event!)
                                ? 'Action Required'
                                : 'Location not received')),
                    style: CustomTextStyles().orange14,
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }

  bool isActionRequired(String? _atsign, EventNotificationModel _event) {
    Iterable<AtContact> _atcontact =
        _event.group!.members!.where((AtContact element) => element.atSign == _atsign);
    // ignore: unnecessary_null_comparison
    if ((_atcontact != null) && (_atcontact.isNotEmpty)) {
      if ((_atcontact.first.tags!['isAccepted'] == false) &&
          (_atcontact.first.tags!['isExited'] == false)) {
        return true;
      }
    }

    return false;
  }
}
