import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/enrollment_request_card.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnrollmentRequestScreen extends StatefulWidget {
  const EnrollmentRequestScreen({super.key});

  @override
  State<EnrollmentRequestScreen> createState() =>
      _EnrollmentRequestScreenState();
}

class _EnrollmentRequestScreenState extends State<EnrollmentRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDateLabel('Today'),
          const SizedBox(height: 12),
          ListView.separated(
            itemCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              return const EnrollmentRequestCard(
                status: RequestStatus.pending,
              );
            },
          ),
          const SizedBox(height: 12),
          buildDateLabel('Tuesday'),
          const SizedBox(height: 12),
          const EnrollmentRequestCard(
            status: RequestStatus.successful,
          ),
          const SizedBox(height: 12),
          const EnrollmentRequestCard(
            status: RequestStatus.expired,
          ),
        ],
      ),
    );
  }

  Widget buildDateLabel(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: ColorConstant.lightGray,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  ///Use this to filter item by date
  ///Using ListView.separated with SizedBox(height: 12) as separator and data of this list
// List<Widget> buildHistoryList(List<DateTime> data) {
//   List<Widget> result = [];
//
//   final DateTime current = DateTime.now();
//
//   final Widget todayLabel = buildDateLabel('Today');
//   Widget thisWeekLabel(String value) => buildDateLabel(value);
//   final Widget lastWeekLabel = buildDateLabel('Last Week');
//   final Widget thisMonthLabel = buildDateLabel('This Month');
//   final Widget lastMonthLabel = buildDateLabel('Last Month');
//   final Widget thisYearLabel = buildDateLabel('This Year');
//   final Widget lastYearLabel = buildDateLabel('Last Year');
//
//   for (int i = 0; i < data.length; i++) {
//     if (isToday(data[i])) {
//       if (!result.contains(todayLabel)) {
//         result.add(todayLabel);
//       }
//     }  else if (isThisWeek(data[i])) {
//       if (!result.contains(thisWeekLabel(getDayOfWeek(data[i].weekday)))) {
//         result.add(thisWeekLabel(getDayOfWeek(data[i].weekday)));
//       }
//     } else if (isLastWeek(data[i])) {
//       if (!result.contains(lastWeekLabel)) {
//         result.add(lastWeekLabel);
//       }
//     } else if ((data[i].year == current.year) &&
//         (data[i].month == current.month)) {
//       if (!result.contains(thisMonthLabel)) {
//         result.add(thisMonthLabel);
//       }
//     } else if (isLastMonth(data[i])) {
//       if (!result.contains(lastMonthLabel)) {
//         result.add(lastMonthLabel);
//       }
//     } else if (data[i].year == current.year) {
//       if (!result.contains(thisYearLabel)) {
//         result.add(thisYearLabel);
//       }
//     } else {
//       if (!result.contains(lastYearLabel)) {
//         result.add(lastYearLabel);
//       }
//     }
//     result.add(
//       EnrollmentRequestCard(
//                 status: RequestStatus.pending,
//               ),
//     );
//   }
//   return result;
// }
//
// bool isToday(DateTime targetDate) {
//   DateFormat dateFormat = DateFormat('yyyy-MM-dd');
//
//   String formattedDate = dateFormat.format(targetDate);
//   String formattedToday = dateFormat.format(DateTime.now());
//   return formattedDate == formattedToday;
// }
//
// bool isThisWeek(DateTime targetDate) {
//   DateTime currentDate = DateTime.now();
//
//   DateTime startOfWeek =
//   currentDate.subtract(Duration(days: currentDate.weekday - 1));
//
//   DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
//
//   return targetDate.isAfter(startOfWeek) && targetDate.isBefore(endOfWeek);
// }
//
// bool isLastWeek(DateTime targetDate) {
//   DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));
//
//   DateTime startOfWeek =
//   currentDate.subtract(Duration(days: currentDate.weekday - 1));
//
//   DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
//
//   return targetDate.isAfter(startOfWeek) && targetDate.isBefore(endOfWeek);
// }
//
// bool isLastMonth(DateTime targetDate) {
//   DateTime now = DateTime.now();
//   DateTime lastMonth = DateTime(now.year, now.month - 1);
//
//   DateFormat dateFormat = DateFormat('yyyy-MM');
//
//   String formattedDate = dateFormat.format(targetDate);
//   String formattedLastMonth = dateFormat.format(lastMonth);
//
//   return formattedDate == formattedLastMonth;
// }
//
// String getDayOfWeek(int day) {
//   switch (day) {
//     case 1:
//       return 'Monday';
//     case 2:
//       return 'Tuesday';
//     case 3:
//       return 'Wednesday';
//     case 4:
//       return 'Thursday';
//     case 5:
//       return 'Friday';
//     case 6:
//       return 'Saturday';
//     case 7:
//       return 'Sunday';
//     default:
//       return '';
//   }
// }
}
