// import 'package:at_location_flutter/location_modal/hybrid_model.dart';
// import 'package:at_location_flutter/service/location_service.dart';
// import 'package:at_location_flutter/utils/constants/colors.dart';
// import 'package:at_location_flutter/utils/constants/text_styles.dart';
// import 'package:flutter/material.dart';
// import 'package:at_common_flutter/services/size_config.dart';

// import 'display_tile.dart';
// import 'draggable_symbol.dart';

// class Participants extends StatelessWidget {
//   bool active;
//   List<HybridModel> data;
//   List<String> atsign;
//   // Key key;
//   // EventNotificationModel eventListenerKeyword;
//   Participants(this.active, {this.data, this.atsign});
//   List<String> untrackedAtsigns = [];
//   List<String> trackedAtsigns = [];

//   @override
//   Widget build(BuildContext context) {
//     print('participants called');
//     untrackedAtsigns = [];
//     trackedAtsigns =
//         data != null ? data.map((e) => e.displayName).toList() : [];

//     atsign.forEach((element) {
//       trackedAtsigns.contains(element)
//           ? print('')
//           : untrackedAtsigns.add(element);
//     });
//     return Container(
//       height: 422.toHeight,
//       padding:
//           EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DraggableSymbol(),
//             CustomHeading(heading: 'Participants', action: 'Cancel'),
//             SizedBox(
//               height: 10.toHeight,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   width: 46.toWidth,
//                   height: 46.toWidth,
//                   decoration: new BoxDecoration(
//                     color: AllColors().MILD_GREY,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Icon(Icons.add, color: AllColors().ORANGE),
//                   ),
//                 ),
//                 SizedBox(width: 20.toWidth),
//                 Text('Add Participant', style: CustomTextStyles().darkGrey16)
//               ],
//             ),
//             SizedBox(
//               height: 10.toHeight,
//             ),
//             active
//                 ? ListView.separated(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: data.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return data[index] == LocationService().eventData
//                           ? SizedBox()
//                           : DisplayTile(
//                               title: data[index].displayName ?? 'user name',
//                               atsignCreator: data[index].displayName,
//                               subTitle: data[index].displayName ?? '@sign',
//                               action: Text(
//                                 // '${widget.data[index].latLng.latitude}, ${widget.data[index].latLng.longitude}' ??
//                                 //     'At the location',
//                                 '${data[index].eta}' ?? 'At the location',
//                                 style: CustomTextStyles().darkGrey14,
//                               ),
//                             );
//                     },
//                     separatorBuilder: (BuildContext context, int index) {
//                       return data[index] == LocationService().eventData
//                           ? Divider()
//                           : SizedBox();
//                     },
//                   )
//                 : ListView.separated(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: atsign.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return DisplayTile(
//                         title: atsign[index] ?? 'user name',
//                         atsignCreator: atsign[index],
//                         subTitle: '@sign',
//                         action: Text(
//                           'Location not received',
//                           style: CustomTextStyles().orange14,
//                         ),
//                       );
//                     },
//                     separatorBuilder: (BuildContext context, int index) {
//                       return Divider();
//                     },
//                   ),
//             active
//                 ? ListView.separated(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: untrackedAtsigns.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return DisplayTile(
//                         title: untrackedAtsigns[index] ?? 'user name',
//                         atsignCreator: untrackedAtsigns[index],
//                         subTitle: '@sign',
//                         action: Text(
//                           'Location not received',
//                           style: CustomTextStyles().orange14,
//                         ),
//                       );
//                     },
//                     separatorBuilder: (BuildContext context, int index) {
//                       return Divider();
//                     },
//                   )
//                 : SizedBox()
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class Participants extends StatefulWidget {
// //   bool active;
// //   List<HybridModel> data;
// //   List<String> atsign;
// //   // Key key;
// //   // EventNotificationModel eventListenerKeyword;
// //   Participants(this.active, {this.data, this.atsign});
// //   @override
// //   _ParticipantsState createState() => _ParticipantsState();
// // }

// // class _ParticipantsState extends State<Participants> {
// //   List<String> untrackedAtsigns = [];
// //   List<String> trackedAtsigns = [];
// //   @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //     // List<HybridModel> tempData = widget.data;
// //     // tempData?.remove(LocationService().eventData);
// //     // widget.data = tempData;
// //     untrackedAtsigns = [];
// //     trackedAtsigns = widget.data != null
// //         ? widget.data.map((e) => e.displayName).toList()
// //         : [];

// //     widget.atsign.forEach((element) {
// //       trackedAtsigns.contains(element)
// //           ? print('')
// //           : untrackedAtsigns.add(element);
// //     });
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     print('didChangeDependencies(),');
// //     super.didChangeDependencies();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     print('participants called');
// //     return Container(
// //       height: 422.toHeight,
// //       padding:
// //           EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
// //       child: SingleChildScrollView(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             DraggableSymbol(),
// //             CustomHeading(heading: 'Participants', action: 'Cancel'),
// //             SizedBox(
// //               height: 10.toHeight,
// //             ),
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: <Widget>[
// //                 Container(
// //                   width: 46.toWidth,
// //                   height: 46.toWidth,
// //                   decoration: new BoxDecoration(
// //                     color: AllColors().MILD_GREY,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Center(
// //                     child: Icon(Icons.add, color: AllColors().ORANGE),
// //                   ),
// //                 ),
// //                 SizedBox(width: 20.toWidth),
// //                 Text('Add Participant', style: CustomTextStyles().darkGrey16)
// //               ],
// //             ),
// //             SizedBox(
// //               height: 10.toHeight,
// //             ),
// //             widget.active
// //                 ? ListView.separated(
// //                     physics: NeverScrollableScrollPhysics(),
// //                     shrinkWrap: true,
// //                     itemCount: widget.data.length,
// //                     itemBuilder: (BuildContext context, int index) {
// //                       return widget.data[index] == LocationService().eventData
// //                           ? SizedBox()
// //                           : DisplayTile(
// //                               title:
// //                                   widget.data[index].displayName ?? 'user name',
// //                               image: widget.data[index].image ??
// //                                   'assets/images/person2.png',
// //                               subTitle:
// //                                   widget.data[index].displayName ?? '@sign',
// //                               action: Text(
// //                                 // '${widget.data[index].latLng.latitude}, ${widget.data[index].latLng.longitude}' ??
// //                                 //     'At the location',
// //                                 '${widget.data[index].eta}' ??
// //                                     'At the location',
// //                                 style: CustomTextStyles().darkGrey14,
// //                               ),
// //                             );
// //                     },
// //                     separatorBuilder: (BuildContext context, int index) {
// //                       return widget.data[index] == LocationService().eventData
// //                           ? Divider()
// //                           : SizedBox();
// //                     },
// //                   )
// //                 : ListView.separated(
// //                     physics: NeverScrollableScrollPhysics(),
// //                     shrinkWrap: true,
// //                     itemCount: widget.atsign.length,
// //                     itemBuilder: (BuildContext context, int index) {
// //                       return DisplayTile(
// //                         title: widget.atsign[index] ?? 'user name',
// //                         image: 'assets/images/person2.png',
// //                         subTitle: '@sign',
// //                         action: Text(
// //                           'Location not received',
// //                           style: CustomTextStyles().orange14,
// //                         ),
// //                       );
// //                     },
// //                     separatorBuilder: (BuildContext context, int index) {
// //                       return Divider();
// //                     },
// //                   ),
// //             widget.active
// //                 ? ListView.separated(
// //                     physics: NeverScrollableScrollPhysics(),
// //                     shrinkWrap: true,
// //                     itemCount: untrackedAtsigns.length,
// //                     itemBuilder: (BuildContext context, int index) {
// //                       return DisplayTile(
// //                         title: untrackedAtsigns[index] ?? 'user name',
// //                         image: 'assets/images/person2.png',
// //                         subTitle: '@sign',
// //                         action: Text(
// //                           'Location not received',
// //                           style: CustomTextStyles().orange14,
// //                         ),
// //                       );
// //                     },
// //                     separatorBuilder: (BuildContext context, int index) {
// //                       return Divider();
// //                     },
// //                   )
// //                 : SizedBox()
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
