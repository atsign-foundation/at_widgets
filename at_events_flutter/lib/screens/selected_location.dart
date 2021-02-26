import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/common_components/floating_icon.dart';
import 'package:at_events_flutter/screens/one_day_event.dart';
import 'package:at_events_flutter/screens/recurring_event.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class SelectedLocation extends StatefulWidget {
  final LatLng point;
  final String displayName;
  SelectedLocation(this.displayName, this.point);
  @override
  _SelectedLocationState createState() => _SelectedLocationState();
}

class _SelectedLocationState extends State<SelectedLocation> {
  List<LatLng> getLatLng() {
    List<List<double>> raw = [
      [148.29, -31.33],
      [148.51, -35.2],
      [149.69, -35.04],
      [149.78, -35.02],
      [149.86, -31.43],
      [150.04, -32.72],
      [150.3, -33.96],
      [150.33, -32.3],
      [150.35, -31.7],
      [150.41, -31.12],
      [150.63, -35.8],
      [150.76, -32.96],
      [150.89, -32.77],
      [150.92, -34.97],
      [151.31, -31.48],
      [151.36, -33.53],
      [151.47, -31.18],
      [151.64, -32.31],
      [151.96, -32.14],
      [152.53, -34.12],
    ];
    return raw.map((e) => LatLng(e[1], e[0])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // Map(
            //   controller: controller,
            //   builder: (context, x, y, z) {
            //     return CachedNetworkImage(
            //       imageUrl: AllText().URL(x, y, z),
            //       fit: BoxFit.cover,
            //     );
            //   },
            // ),
            // AtLocationFlutterPlugin(),
            ShowLocation(UniqueKey(), location: LatLng(20, 30)),
            Positioned(
              top: 0,
              left: 0,
              child: FloatingIcon(
                bgColor: AllColors().WHITE,
                icon: Icons.arrow_back,
                iconColor: AllColors().Black,
                isTopLeft: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                    28.toWidth, 20.toHeight, 28.toHeight, 0),
                height: SizeConfig().screenHeight * 0.4,
                width: SizeConfig().screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AllColors().ORANGE,
                                    ),
                                    Text('', style: CustomTextStyles().black16)
                                  ],
                                ),
                              ),
                              InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: CustomTextStyles().orange16))
                            ],
                          ),
                          SizedBox(height: 10.toHeight),
                          Flexible(
                            child: Text(widget.displayName,
                                style: CustomTextStyles().greyLabel14),
                          ),
                          SizedBox(height: 20.toHeight),
                          Text('Label', style: CustomTextStyles().greyLabel14),
                          SizedBox(height: 5.toHeight),
                          CustomInputField(
                            width: 321.toWidth,
                            hintText: 'Save this address as',
                            initialValue: EventService()
                                .eventNotificationModel
                                .venue
                                .label,
                            value: (String val) {
                              EventService()
                                  .eventNotificationModel
                                  .venue
                                  .label = val;
                            },
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 20.toHeight),
                        child: CustomButton(
                          buttonText: 'Save',
                          onPressed: () {
                            EventService()
                                .eventNotificationModel
                                .venue
                                .latitude = widget.point.latitude;

                            EventService()
                                .eventNotificationModel
                                .venue
                                .longitude = widget.point.longitude;

                            EventService().update(
                                eventData:
                                    EventService().eventNotificationModel);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          width: 165.toWidth,
                          height: 48.toHeight,
                          buttonColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? AllColors().Black
                                  : AllColors().WHITE,
                          fontColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? AllColors().WHITE
                                  : AllColors().Black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
