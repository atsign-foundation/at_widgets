import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:at_chat_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_location_flutter/common_components/pointed_bottom.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:flutter/material.dart';

Widget buildPopup(HybridModel user) {
  print('popup builder called');
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 200,
        height: 82,
        alignment: Alignment.topCenter,
        child: Container(
          color: Colors.white,
          height: 76,
          child: Row(
            children: [
              (LocationService().eventListenerKeyword != null) &&
                      (user == LocationService().eventData)
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.blue[100],
                      child: Column(
                        children: [
                          Icon(
                            Icons.car_rental,
                            color: Colors.grey[600],
                            size: 32,
                          ),
                          Text(
                            // eta.length > index ? eta[index] : '?',
                            user.eta ?? '?',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: user.image != null
                            ? CustomCircleAvatar(
                                byteImage: user.image, nonAsset: true, size: 30)
                            : ContactInitial(
                                initials: user.displayName.substring(1, 3),
                                size: 60,
                              ),
                      ),
                      Text(
                        user.displayName ??
                            'AnthonyAnthonyAnthonyAnthonyAnthony',
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
      Positioned(bottom: 0, child: pointedBottom())
    ],
  );
}
