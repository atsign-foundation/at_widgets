import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_events_flutter/common_components/custom_heading.dart';
import 'package:at_events_flutter/common_components/display_tile.dart';
import 'package:at_events_flutter/common_components/draggable_symbol.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:flutter/material.dart';

import 'events_map_screen.dart';

class Participants extends StatefulWidget {
  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  List<String?> untrackedAtsigns = [];

  List<String?> trackedAtsigns = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ValueListenableBuilder(
          valueListenable: EventsMapScreenData().eventNotifier!,
          builder: (BuildContext context, EventNotificationModel? _event,
              Widget? child) {
            for (var member in _event!.group!.members!) {
              if ((member.atSign!) !=
                  AtClientManager.getInstance().atClient.getCurrentAtSign()!) {
                if (MasterLocationService().getHybridModel(member.atSign!) !=
                    null) {
                  trackedAtsigns.add(member.atSign!);
                } else {
                  untrackedAtsigns.add(member.atSign!);
                }
              }
            }

            if ((_event.atsignCreator) !=
                AtClientManager.getInstance().atClient.getCurrentAtSign()!) {
              if (MasterLocationService()
                      .getHybridModel(_event.atsignCreator!) !=
                  null) {
                trackedAtsigns.add(_event.atsignCreator!);
              } else {
                untrackedAtsigns.add(_event.atsignCreator!);
              }
            }

            // var _locationList = EventsMapScreenData().markers;
            // untrackedAtsigns = [];
            // // ignore: unnecessary_null_comparison
            // trackedAtsigns = _locationList != null
            //     ? _locationList.map((e) => e.displayName).toList()
            //     : [];

            // /// for creator
            // trackedAtsigns.contains(_event!.atsignCreator)
            //     ? print('')
            //     : untrackedAtsigns.add(_event.atsignCreator);

            // /// for members
            // _event.group!.members!.forEach((element) => {
            //       trackedAtsigns.contains(element.atSign)
            //           ? print('')
            //           : untrackedAtsigns.add(element.atSign)
            //     });

            List<HybridModel?> _hybridUsersList = [];

            return Text('temporary participants list');

            // return builder(LocationService().hybridUsersList, _event);
          }),
    );
  }

  Widget builder(List<HybridModel?> _markers, EventNotificationModel? _event) {
    return Container(
      height: 422.toHeight,
      padding:
          EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DraggableSymbol(),
            CustomHeading(heading: 'Participants', action: 'Close'),
            SizedBox(
              height: 10.toHeight,
            ),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _markers.length,
              itemBuilder: (BuildContext context, int index) {
                return _markers[index]!.displayName == _event!.venue!.label
                    ? SizedBox()
                    : DisplayTile(
                        title: _markers[index]!.displayName! ?? '',
                        atsignCreator: _markers[index]!.displayName,
                        subTitle: null,
                        action: Text(
                          (_markers[index]!.displayName ==
                                  AtEventNotificationListener().currentAtSign)
                              ? ''
                              : '${_markers[index]!.eta}',
                          style: CustomTextStyles().darkGrey14,
                        ),
                      );
              },
              separatorBuilder: (BuildContext context, int index) {
                return _markers[index]!.displayName != _event!.venue!.label
                    ? Divider()
                    : SizedBox();
              },
            ),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
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
                return SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }

  bool isActionRequired(String? _atsign, EventNotificationModel _event) {
    var _atcontact =
        _event.group!.members!.where((element) => element.atSign == _atsign);
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
