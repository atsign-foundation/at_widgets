import 'package:at_location_flutter/common_components/pointed_bottom.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:flutter/material.dart';

import 'contacts_initial.dart';
import 'custom_circle_avatar.dart';

Widget buildPopup(HybridModel user) {
  bool showEtaSection = true;
  if (LocationService().etaFrom != null) {
    if (user.latLng == LocationService().etaFrom) showEtaSection = false;
  } else if (user.latLng == LocationService().myData.latLng)
    showEtaSection = false;

  return Stack(
    alignment: Alignment.center,
    children: [
      Positioned(bottom: 0, child: pointedBottom()),
      Container(
        width:
            ((LocationService().calculateETA) && (showEtaSection)) ? 200 : 140,
        height: 82,
        alignment: Alignment.topCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Container(
            color: Colors.white,
            height: 76,
            child: Row(
              mainAxisAlignment:
                  ((LocationService().calculateETA) && (showEtaSection))
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
              children: [
                ((LocationService().calculateETA) && (showEtaSection))
                    ? Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.blue[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.car_rental,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                              Flexible(
                                child: Text(
                                  user.eta ?? '?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[600]),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: user.image != null
                              ? CustomCircleAvatar(
                                  byteImage: user.image,
                                  nonAsset: true,
                                  size: 30)
                              : ContactInitial(
                                  initials: user.displayName.substring(1, 3),
                                  size: 60,
                                ),
                        ),
                        Text(
                          user.displayName ?? '...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
