enum LOC_START_TIME_ENUM { TWO_HOURS, SIXTY_MIN, THIRTY_MIN }
enum LOC_END_TIME_ENUM { TEN_MIN, AFTER_EVERY_ONE_REACHED, AT_EOD }

// ignore: missing_return
DateTime? startTimeEnumToTimeOfDay(String startTimeEnum, DateTime? startTime) {
  // ignore: unnecessary_null_comparison
  if (startTimeEnum == null ||
      // ignore: prefer_is_empty
      startTimeEnum.trim().length == 0 ||
      startTime == null) {
    return startTime;
  }
  switch (startTimeEnum.toString()) {
    case 'LOC_START_TIME_ENUM.TWO_HOURS':
      return startTime.subtract(const Duration(hours: 2));

    case 'LOC_START_TIME_ENUM.SIXTY_MIN':
      return startTime.subtract(const Duration(minutes: 60));

    case 'LOC_START_TIME_ENUM.THIRTY_MIN':
      return startTime.subtract(const Duration(minutes: 30));
  }
}

// ignore: missing_return
DateTime? endTimeEnumToTimeOfDay(String endTimeEnum, DateTime? endTime) {
  // ignore: unnecessary_null_comparison
  if (endTimeEnum == null ||
      // ignore: prefer_is_empty
      endTimeEnum.trim().length == 0 ||
      endTime == null) {
    return endTime;
  }
  switch (endTimeEnum.toString()) {
    case 'LOC_END_TIME_ENUM.TEN_MIN':
      return endTime.add(const Duration(minutes: 10));

    case 'LOC_END_TIME_ENUM.AFTER_EVERY_ONE_REACHED':
      return endTime;

    case 'LOC_END_TIME_ENUM.AT_EOD':
      DateTime nextDay = DateTime(endTime.year, endTime.month, endTime.day + 1);
      Duration addDuration = nextDay.difference(endTime);
      return endTime.add(addDuration);
  }
}
