import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/common_components/location_tile.dart';
import 'package:at_events_flutter/screens/selected_location.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/location_modal/location_modal.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({Key? key}) : super(key: key);

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  String inputText = '';
  bool isLoader = false;
  bool? nearMe;
  LatLng? currentLocation;
  @override
  void initState() {
    calculateLocation();
    super.initState();
  }

  /// nearMe == null => loading
  /// nearMe == false => dont search nearme
  /// nearMe == true => search nearme
  /// nearMe == false && currentLocation == null =>dont search nearme
  // ignore: always_declare_return_types
  calculateLocation() async {
    currentLocation = await getMyLocation();
    if (currentLocation != null) {
      nearMe = true;
    } else {
      nearMe = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.8,
      padding: EdgeInsets.fromLTRB(28.toWidth, 20.toHeight, 17.toWidth, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: CustomInputField(
                  hintText: 'Search an area, street name…',
                  height: 50.toHeight,
                  initialValue: inputText,
                  onSubmitted: (String str) async {
                    setState(() {
                      isLoader = true;
                    });
                    if ((nearMe == null) || (!nearMe!)) {
                      // ignore: await_only_futures
                      SearchLocationService().getAddressLatLng(str, null);
                    } else {
                      // ignore: await_only_futures
                      SearchLocationService()
                          .getAddressLatLng(str, currentLocation!);
                    }

                    setState(() {
                      isLoader = false;
                    });
                  },
                  value: (val) {
                    inputText = val;
                  },
                  icon: Icons.search,
                  onIconTap: () async {
                    setState(() {
                      isLoader = true;
                    });
                    if ((nearMe == null) || (!nearMe!)) {
                      // ignore: await_only_futures
                      SearchLocationService().getAddressLatLng(inputText, null);
                    } else {
                      // ignore: await_only_futures
                      SearchLocationService()
                          .getAddressLatLng(inputText, currentLocation!);
                    }
                    setState(() {
                      isLoader = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 10.toWidth),
              Column(
                children: [
                  InkWell(
                      onTap: () => Navigator.pop(context),
                      child:
                          Text('Cancel', style: CustomTextStyles().orange16)),
                ],
              ),
            ],
          ),
          SizedBox(height: 5.toHeight),
          Row(
            children: <Widget>[
              Checkbox(
                value: nearMe,
                tristate: true,
                onChanged: (value) async {
                  if (nearMe == null) return;

                  if (!nearMe!) {
                    currentLocation = await getMyLocation();
                  }

                  if (currentLocation == null) {
                    CustomToast().show('Unable to access location', context,
                        isError: true);
                    setState(() {
                      nearMe = false;
                    });
                    return;
                  }

                  setState(() {
                    nearMe = !nearMe!;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Near me', style: CustomTextStyles().greyLabel14),
                    ((nearMe == null) ||
                            ((nearMe == false) && (currentLocation == null)))
                        ? Flexible(
                            child: Text('(Cannot access location permission)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CustomTextStyles().red12),
                          )
                        : const SizedBox()
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5.toHeight),
          const Divider(),
          SizedBox(height: 18.toHeight),
          InkWell(
            onTap: () async {
              if (currentLocation == null) {
                CustomToast()
                    .show('Unable to access location', context, isError: true);
                return;
              }
              onLocationSelect(context, currentLocation!);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location', style: CustomTextStyles().greyLabel14),
                SizedBox(height: 5.toHeight),
                Text('Using GPS', style: CustomTextStyles().greyLabel12),
              ],
            ),
          ),
          SizedBox(height: 20.toHeight),
          const Divider(),
          SizedBox(height: 20.toHeight),
          isLoader
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
          StreamBuilder(
            stream: SearchLocationService().atLocationStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<LocationModal>> snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox()
                  : snapshot.hasData
                      // ignore: prefer_is_empty
                      ? snapshot.data!.length == 0
                          ? const Text('No such location found')
                          : Expanded(
                              child: ListView.separated(
                                itemCount: snapshot.data!.length,
                                separatorBuilder: (context, index) {
                                  return Column(
                                    children: const [
                                      SizedBox(height: 20),
                                      Divider(),
                                    ],
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () => onLocationSelect(
                                      context,
                                      LatLng(
                                          double.parse(
                                              snapshot.data![index].lat!),
                                          double.parse(
                                              snapshot.data![index].long!)),
                                      displayName:
                                          snapshot.data![index].displayName,
                                    ),
                                    child: LocationTile(
                                      icon: Icons.location_on,
                                      title: snapshot.data![index].city,
                                      subTitle:
                                          snapshot.data![index].displayName,
                                    ),
                                  );
                                },
                              ),
                            )
                      : snapshot.hasError
                          ? const Text('Something Went wrong')
                          : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

void onLocationSelect(BuildContext context, LatLng point,
    {String? displayName}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SelectedLocation(displayName ?? 'Your location', point)));
}
