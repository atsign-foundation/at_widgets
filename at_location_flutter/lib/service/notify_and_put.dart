import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_client/src/service/notification_service.dart';

class NotifyAndPut {
  NotifyAndPut._();
  static final NotifyAndPut _instance = NotifyAndPut._();
  factory NotifyAndPut() => _instance;

  Future<bool> notifyAndPut(AtKey atKey, dynamic value,
      {bool saveDataIfUndelivered = false}) async {
    try {
      if (!atKey.sharedBy!.contains('@')) {
        atKey.sharedBy = '@' + atKey.sharedBy!;
      }

      if (!atKey.sharedWith!.contains('@')) {
        atKey.sharedWith = '@' + atKey.sharedWith!;
      }

      var result =
          await AtClientManager.getInstance().notificationService.notify(
                NotificationParams.forUpdate(
                  atKey,
                  value: value,
                ),
              );

      print(
          'notifyAndPut result for $atKey - $result ${result.atClientException}');

      if ((saveDataIfUndelivered) ||
          (result.notificationStatusEnum == NotificationStatusEnum.delivered)) {
        atKey.sharedWith = null;
        await AtClientManager.getInstance().atClient.put(
              atKey,
              value,
            );
        return true;
      }
      return false;
    } catch (e) {
      print('Error in notifyAndPut $e');
      return false;
    }
  }
}
