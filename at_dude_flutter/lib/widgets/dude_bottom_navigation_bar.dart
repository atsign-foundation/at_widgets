// import 'package:at_dude_flutter/dude_theme.dart';
// import 'package:at_dude_flutter/screens/history_screen.dart';
// import 'package:at_dude_flutter/screens/send_dude_screen.dart';
// import 'package:at_dude_flutter/services/dude_service.dart';
// import 'package:badges/badges.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class DudeBottomNavigationBar extends StatefulWidget {
//   const DudeBottomNavigationBar({required this.selectedIndex, Key? key})
//       : super(key: key);
//
//   final int selectedIndex;
//   @override
//   State<DudeBottomNavigationBar> createState() =>
//       _DudeBottomNavigationBarState();
// }
//
// class _DudeBottomNavigationBarState extends State<DudeBottomNavigationBar> {
//   void _handleOnTap(int currentIndex) {
//     if (currentIndex == 0) {
//       Navigator.of(context).popAndPushNamed(SendDudeScreen.routeName);
//     } else {
//       Navigator.of(context).popAndPushNamed(HistoryScreen.routeName);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int dudeCount = Provider.of<DudeService>(context).dudes.length;
//     return BottomNavigationBar(
//         currentIndex: widget.selectedIndex,
//         onTap: _handleOnTap,
//         items: <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.send_outlined),
//             label: 'Send Dude',
//           ),
//           BottomNavigationBarItem(
//             icon: Badge(
//                 elevation: dudeCount > 0 ? 2 : 0,
//                 badgeColor: Theme.of(context).bottomAppBarColor,
//                 badgeContent: dudeCount > 0
//                     ? Text(dudeCount.toString(),
//                         style: const TextStyle(
//                           color: kAlternativeColor,
//                         ))
//                     : null,
//                 child: const Icon(Icons.history_outlined)),
//             label: 'History',
//           ),
//         ]);
//   }
// }
